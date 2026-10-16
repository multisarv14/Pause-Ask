import "../setup";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onCall } from "firebase-functions/v2/https";

import { LIMITS } from "../config";
import { requireUid } from "../lib/auth";
import { fail } from "../lib/errors";
import { istDayKey } from "../lib/istDay";
import { maskText } from "../lib/masking";
import { refs } from "../lib/refs";
import { GEMINI_API_KEY, createLlmProvider } from "../llm/provider";
import {
  CheckResult,
  LANGUAGES,
  Language,
  checkResultJsonSchema,
  fallbackResult,
  parseCheckResult,
} from "./checkResult";
import { CheckSource, buildSystemPrompt, buildUserPrompt } from "./prompt";

const SOURCES: readonly CheckSource[] = ["share", "image", "voice", "typed"];
const DAY_MS = 24 * 60 * 60 * 1000;

interface CheckInput {
  text: string;
  source: CheckSource;
  language: Language;
}

function parseInput(data: unknown): CheckInput {
  const d = (data ?? {}) as Record<string, unknown>;
  if (typeof d.text !== "string" || d.text.trim().length === 0) fail("INVALID_TEXT");
  if (d.text.length > LIMITS.maxCheckTextLength) fail("TEXT_TOO_LONG");
  if (!SOURCES.includes(d.source as CheckSource)) fail("INVALID_ARGUMENT");
  if (!LANGUAGES.includes(d.language as Language)) fail("INVALID_ARGUMENT");
  return {
    text: d.text.trim(),
    source: d.source as CheckSource,
    language: d.language as Language,
  };
}

/** Counts this check against today's (Asia/Kolkata) limit, atomically. */
async function consumeDailyCheck(uid: string): Promise<number> {
  const day = istDayKey();
  const ref = refs.usage(uid, day);
  return getFirestore().runTransaction(async (tx) => {
    const used = ((await tx.get(ref)).data()?.count as number | undefined) ?? 0;
    if (used >= LIMITS.maxChecksPerDay) fail("DAILY_LIMIT_REACHED");
    tx.set(ref, {
      uid,
      day,
      count: used + 1,
      updatedAt: FieldValue.serverTimestamp(),
      // Usage docs are only needed for a day; TTL can clean them up.
      expireAt: Timestamp.fromMillis(Date.now() + 2 * DAY_MS),
    });
    return used + 1;
  });
}

/** Never includes the error message: it could echo message content. */
function describeError(e: unknown) {
  const err = e as { name?: string; status?: number; code?: unknown };
  return { name: err?.name ?? typeof e, status: err?.status, code: err?.code };
}

/**
 * analyzeCheck({ text, source, language }) → { checkId, result }
 * Masks private data, asks the AI for a risk level (never "safe") and
 * stores the check for 30 days. The raw text is never logged or stored.
 */
export const analyzeCheck = onCall(
  { secrets: [GEMINI_API_KEY], timeoutSeconds: 60, memory: "512MiB" },
  async (req) => {
    const uid = requireUid(req);
    const input = parseInput(req.data);
    const usedToday = await consumeDailyCheck(uid);

    const maskedText = maskText(input.text);
    const started = Date.now();
    let result: CheckResult;
    let aiStatus: string;
    let provider = "unknown";
    try {
      const llm = createLlmProvider();
      provider = llm.name;
      const raw = await llm.generateJson({
        system: buildSystemPrompt(input.language),
        user: buildUserPrompt(maskedText, input.source),
        jsonSchema: checkResultJsonSchema,
        timeoutMs: LIMITS.llmTimeoutMs,
      });
      const outcome = parseCheckResult(raw, input.language);
      result = outcome.result;
      aiStatus = outcome.ok ? "ok" : `fallback:${outcome.reason}`;
    } catch (e) {
      logger.warn("LLM call failed", { uid, provider, error: describeError(e) });
      result = fallbackResult(input.language);
      aiStatus = "fallback:error";
    }

    const membership = await refs.membership(uid).get();
    const createdAt = Timestamp.now();
    const checkRef = refs.checks().doc();
    await checkRef.set({
      uid,
      circleId: (membership.data()?.circleId as string | undefined) ?? null,
      maskedText,
      source: input.source,
      language: input.language,
      result,
      aiStatus,
      createdAt,
      // Firestore TTL policy on checks.expireAt deletes the doc after 30 days.
      expireAt: Timestamp.fromMillis(
        createdAt.toMillis() + LIMITS.checkRetentionDays * DAY_MS,
      ),
      guardianResponse: null,
    });

    // Metadata only: no message text, masked or not.
    logger.info("check analyzed", {
      uid,
      checkId: checkRef.id,
      source: input.source,
      language: input.language,
      textLength: input.text.length,
      riskLevel: result.riskLevel,
      aiStatus,
      provider,
      usedToday,
      ms: Date.now() - started,
    });

    return { checkId: checkRef.id, result };
  },
);
