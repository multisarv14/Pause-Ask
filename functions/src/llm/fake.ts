import type { LlmProvider, LlmRequest } from "./provider";

/**
 * Deterministic stand-in for tests in the emulator (LLM_PROVIDER=fake).
 * Magic words in the message trigger the edge cases.
 */
export class FakeProvider implements LlmProvider {
  readonly name = "fake";

  async generateJson(req: LlmRequest): Promise<string> {
    const text = req.user;
    if (text.includes("FAKE_NOT_JSON")) return "Sorry, I can't help with that.";
    if (text.includes("FAKE_THROW")) throw new Error("fake provider failure");
    if (text.includes("FAKE_SAYS_SAFE")) {
      return JSON.stringify({
        riskLevel: "BE_CAREFUL",
        scamType: "None",
        redFlags: [],
        whatToDo: ["a", "b", "c"],
        summary: "This message is safe.",
      });
    }
    const high = /CBI|police|Aadhaar|disconnect/i.test(text);
    return JSON.stringify({
      riskLevel: high ? "HIGH" : "BE_CAREFUL",
      scamType: high ? "Digital arrest" : "Unclear",
      redFlags: high ? ["Threat from a fake officer", "Asks for money"] : [],
      whatToDo: [
        "Do not send money.",
        "Call the official number you already know.",
        "Ask a family member.",
      ],
      summary: high ? "This looks like a scam." : "Be careful with this message.",
    });
  }
}
