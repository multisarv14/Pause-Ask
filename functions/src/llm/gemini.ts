import { GoogleGenAI } from "@google/genai";

import type { LlmProvider, LlmRequest } from "./provider";

export class GeminiProvider implements LlmProvider {
  readonly name = "gemini";
  private readonly client: GoogleGenAI;

  constructor(
    apiKey: string,
    private readonly model: string,
  ) {
    if (!apiKey) throw new Error("GEMINI_API_KEY is not set");
    this.client = new GoogleGenAI({ apiKey });
  }

  async generateJson(req: LlmRequest): Promise<string> {
    const response = await this.client.models.generateContent({
      model: this.model,
      contents: req.user,
      config: {
        systemInstruction: req.system,
        responseMimeType: "application/json",
        responseJsonSchema: req.jsonSchema,
        temperature: 0.2,
        maxOutputTokens: 2048,
        abortSignal: AbortSignal.timeout(req.timeoutMs),
      },
    });
    return response.text ?? "";
  }
}
