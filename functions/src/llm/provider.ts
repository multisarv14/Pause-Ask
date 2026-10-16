import { defineSecret, defineString } from "firebase-functions/params";

import { AnthropicProvider } from "./anthropic";
import { FakeProvider } from "./fake";
import { GeminiProvider } from "./gemini";

export interface LlmRequest {
  system: string;
  user: string;
  /** JSON schema the reply must follow. */
  jsonSchema: object;
  timeoutMs: number;
}

/** A model that returns a JSON string for a system + user prompt. */
export interface LlmProvider {
  readonly name: string;
  generateJson(req: LlmRequest): Promise<string>;
}

/** "gemini" (default) | "anthropic" (stub) | "fake" (emulator only). */
export const LLM_PROVIDER = defineString("LLM_PROVIDER", { default: "gemini" });
export const GEMINI_MODEL = defineString("GEMINI_MODEL", {
  default: "gemini-3.8-flash",
});

/** Stored in Secret Manager; never in code, .env or the app. */
export const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
// When switching to Anthropic: add defineSecret("ANTHROPIC_API_KEY") and
// list it in analyzeCheck's `secrets`.

export function createLlmProvider(): LlmProvider {
  const name = LLM_PROVIDER.value();
  switch (name) {
    case "gemini":
      return new GeminiProvider(GEMINI_API_KEY.value(), GEMINI_MODEL.value());
    case "anthropic":
      return new AnthropicProvider();
    case "fake":
      if (process.env.FUNCTIONS_EMULATOR !== "true") {
        throw new Error("The fake LLM provider is only allowed in the emulator");
      }
      return new FakeProvider();
    default:
      throw new Error(`Unknown LLM_PROVIDER "${name}"`);
  }
}
