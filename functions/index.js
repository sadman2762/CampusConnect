const { onCall } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const MODEL_NAME = "models/gemini-2.5-pro";

// ✅ 1. Keep your original chat function
exports.chatWithGemini = onCall(
  {
    region: "us-central1",
    secrets: ["GEMINI_KEY"],
  },
  async (req) => {
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

// ✅ 2. Add translation function below it
exports.translateWithGemini = onCall(
  {
    region: "us-central1",
    secrets: ["GEMINI_KEY"],
  },
  async (req) => {
    const geminiKey = process.env.GEMINI_KEY;
    if (!geminiKey) {
      console.error("❌ Missing GEMINI_KEY environment variable");
      return { reply: "⚠️ Configuration error: missing API key." };
    }

    const genAI = new GoogleGenerativeAI(geminiKey);

    const text = req.data?.text;
    const targetLang = req.data?.targetLang || "English";

    if (!text || typeof text !== "string") {
      return { reply: "❗ Invalid input text." };
    }

    const prompt = `
Translate the word or sentence below into ${targetLang}, and format the result like this:

 <meaning 1> or <meaning 2> or<if it has more meaning>(Language name)
 just give one line answer that is meaning , no original text

Example:
Hi or Bye (Hungarian)

Now translate this:
"${text}"
`;


    try {
      const model = genAI.getGenerativeModel({ model: MODEL_NAME });
      const result = await model.generateContent([prompt]);
      const translation = result.response.text();

      return { reply: translation || "🤖 Gemini returned no result." };
    } catch (e) {
      console.error("❌ Gemini translation error:", e);
      return {
        reply: "⚠️ Gemini failed to translate. Please try again later.",
        error: e.message,
      };
    }
  }
);
