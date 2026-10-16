import type { LlmProvider, LlmRequest } from "./provider";

/**
 * Placeholder so the provider can be switched by config later
 * (LLM_PROVIDER=anthropic). Not implemented in v1: analyzeCheck catches
 * this error and returns the BE_CAREFUL fallback.
 */
export class AnthropicProvider implements LlmProvider {
  readonly name = "anthropic";

  async generateJson(_req: LlmRequest): Promise<string> {
    throw new Error("Anthropic provider is not implemented yet");
  }
}
