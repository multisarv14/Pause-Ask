import { z } from "zod";

export const LANGUAGES = ["en", "hi", "mr"] as const;
export type Language = (typeof LANGUAGES)[number];

/** There is deliberately no "SAFE" level: only a guardian can say OK. */
export const RISK_LEVELS = ["HIGH", "SUSPICIOUS", "BE_CAREFUL"] as const;

const shortText = (max: number) => z.string().trim().min(1).max(max);

export const checkResultSchema = z.object({
  riskLevel: z.enum(RISK_LEVELS),
  scamType: shortText(80),
  // Extra items are trimmed rather than rejected.
  redFlags: z.array(shortText(160)).transform((a) => a.slice(0, 5)),
  whatToDo: z
    .array(shortText(160))
    .min(3)
    .transform((a) => a.slice(0, 3)),
  summary: shortText(400),
});

export type CheckResult = z.output<typeof checkResultSchema>;

/** JSON schema handed to the model (mirrors checkResultSchema). */
export const checkResultJsonSchema = {
  type: "object",
  properties: {
    riskLevel: { type: "string", enum: [...RISK_LEVELS] },
    scamType: { type: "string" },
    redFlags: { type: "array", items: { type: "string" }, maxItems: 5 },
    whatToDo: {
      type: "array",
      items: { type: "string" },
      minItems: 3,
      maxItems: 3,
    },
    summary: { type: "string" },
  },
  required: ["riskLevel", "scamType", "redFlags", "whatToDo", "summary"],
} as const;

/**
 * Phrases that declare a message safe / genuine in en, hi or mr.
 * Words like "safe account" inside a red flag are fine; a verdict is not.
 */
const SAFE_VERDICT_PATTERNS: RegExp[] = [
  /\b(?:is|are|looks|seems|appears|it's|its)\s+(?:to\s+be\s+)?(?:completely\s+|totally\s+|perfectly\s+|probably\s+|likely\s+)?(?:safe|genuine|legit(?:imate)?|authentic|harmless|trustworthy|real)\b/i,
  /\bnot\s+(?:a\s+)?(?:scam|fraud|fake)\b/i,
  /\b(?:no|zero)\s+(?:risk|danger|threat)\b/i,
  /^\s*(?:safe|genuine|legitimate|not\s+a\s+scam)\s*$/i,
  // Hindi
  /(?:सुरक्षित|असली|भरोसेमंद|सही)\s*(?:है|हैं|लगता|लगती|लग\s*रहा|प्रतीत)/,
  /(?:धोखा|धोखाधड़ी|फ्रॉड|स्कैम|ठगी)\s*नहीं\s*है/,
  /कोई\s*(?:खतरा|ख़तरा|जोखिम)\s*नहीं/,
  // Marathi
  /(?:सुरक्षित|खरा|खरी|खरं|खरे|विश्वासार्ह)\s*(?:आहे|आहेत|वाटतो|वाटते|वाटतं|दिसतो|दिसते|दिसतं)/,
  /(?:फसवणूक|स्कॅम|फ्रॉड)\s*नाही/,
  /कोणताही\s*धोका\s*नाही/,
];

export function containsSafeVerdict(result: CheckResult): boolean {
  const texts = [result.scamType, result.summary, ...result.redFlags];
  return texts.some((t) => SAFE_VERDICT_PATTERNS.some((re) => re.test(t)));
}

const FALLBACKS: Record<Language, CheckResult> = {
  en: {
    riskLevel: "BE_CAREFUL",
    scamType: "Could not check fully",
    redFlags: [],
    whatToDo: [
      "Do not click any link or call any number in this message.",
      "Do not share your OTP, PIN or bank details with anyone.",
      "Ask a family member before you do anything.",
    ],
    summary:
      "We could not check this message properly. Please be careful and ask your family before you act.",
  },
  hi: {
    riskLevel: "BE_CAREFUL",
    scamType: "पूरी जाँच नहीं हो पाई",
    redFlags: [],
    whatToDo: [
      "इस मैसेज के किसी लिंक पर क्लिक न करें और दिए गए नंबर पर फ़ोन न करें।",
      "OTP, PIN या बैंक की जानकारी किसी को न बताएँ।",
      "कुछ भी करने से पहले परिवार के किसी सदस्य से पूछ लें।",
    ],
    summary:
      "हम इस मैसेज की ठीक से जाँच नहीं कर पाए। सावधान रहें और कुछ भी करने से पहले परिवार से पूछें।",
  },
  mr: {
    riskLevel: "BE_CAREFUL",
    scamType: "पूर्ण तपासणी होऊ शकली नाही",
    redFlags: [],
    whatToDo: [
      "या मेसेजमधील कोणत्याही लिंकवर क्लिक करू नका आणि दिलेल्या नंबरवर फोन करू नका.",
      "OTP, PIN किंवा बँकेची माहिती कोणालाही सांगू नका.",
      "काहीही करण्याआधी कुटुंबातील एखाद्या सदस्याला विचारा.",
    ],
    summary:
      "आम्ही हा मेसेज नीट तपासू शकलो नाही. सावध राहा आणि काहीही करण्याआधी कुटुंबाला विचारा.",
  },
};

export function fallbackResult(language: Language): CheckResult {
  const f = FALLBACKS[language];
  return { ...f, redFlags: [...f.redFlags], whatToDo: [...f.whatToDo] };
}

export type ParseOutcome =
  | { ok: true; result: CheckResult }
  | { ok: false; reason: "not_json" | "schema" | "safe_verdict"; result: CheckResult };

/** Parses the model's reply; anything unusable becomes the BE_CAREFUL fallback. */
export function parseCheckResult(raw: string, language: Language): ParseOutcome {
  const fallback = fallbackResult(language);
  let json: unknown;
  try {
    // Tolerate ```json fences.
    json = JSON.parse(raw.trim().replace(/^```(?:json)?\s*|\s*```$/g, ""));
  } catch {
    return { ok: false, reason: "not_json", result: fallback };
  }
  const parsed = checkResultSchema.safeParse(json);
  if (!parsed.success) return { ok: false, reason: "schema", result: fallback };
  if (containsSafeVerdict(parsed.data)) {
    return { ok: false, reason: "safe_verdict", result: fallback };
  }
  return { ok: true, result: parsed.data };
}
