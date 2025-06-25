const { onCall } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");

// TODO: Replace with the exact model name you saw from ListModels (e.g. "models/gemini-2.5-pro")
const MODEL_NAME = "models/gemini-2.5-pro";

// Initialize generative AI client later within the handler to ensure secrets are loaded at runtime
// exports.chatWithGemini will have access to the GEMINI_KEY env var due to the 'secrets' configuration
exports.chatWithGemini = onCall(
  {
    region: "us-central1",
    secrets: ["GEMINI_KEY"],
  },
  async (req) => {
    // Get the API key from environment (loaded at runtime via Secret Manager)
    const geminiKey = process.env.GEMINI_KEY;
    if (!geminiKey) {
      console.error("❌ Missing GEMINI_KEY environment variable");
      return { reply: "⚠️ Configuration error: missing API key." };
    }

    const genAI = new GoogleGenerativeAI(geminiKey);

    const prompt = req.data?.prompt;
    if (!prompt || typeof prompt !== "string") {
      return { reply: "❗ Invalid prompt provided." };
    }

    try {
      const model = genAI.getGenerativeModel({ model: MODEL_NAME });
      const result = await model.generateContent([prompt]);
      const text = result.response.text();

      return { reply: text || "🤖 Gemini had no response." };
    } catch (e) {
      console.error("❌ Gemini error:", e);
      return {
        reply: "⚠️ Gemini failed to respond. Please try again later.",
        error: e.message,
      };
    }
  }
);
