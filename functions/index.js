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
// 1) Admin SDK
const admin = require('firebase-admin');
admin.initializeApp();

// 2) v2 triggers
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onSchedule }      = require('firebase-functions/v2/scheduler');
////////////////////////////////////////////////////////////////////////////////
// 3) Enqueue AFTER seen (v2 onDocumentUpdated)
//    Fires only when someone new is added to `seenBy` on a secret message
////////////////////////////////////////////////////////////////////////////////
exports.enqueueOnSeen = onDocumentUpdated(
  {
    region:   'us-central1',
    document: 'guidance_chats/{chatId}/messages/{msgId}',
  },
  async (event) => {
    const path = event.ref.path;
    console.log('enqueueOnSeen fired for', path);

    const before = event.data.before.data() || {};
    const after  = event.data.after.data()  || {};
    console.log('  seenBefore:', before.seenBy, 'seenAfter:', after.seenBy);

    // only secret‐mode messages
    if (!after.isSecret) {
      console.log('  skipping: not secret');
      return;
    }

    // if no new viewer, skip
    const seenBefore = Array.isArray(before.seenBy) ? before.seenBy : [];
    const seenAfter  = Array.isArray(after.seenBy)  ? after.seenBy  : [];
    if (seenAfter.length <= seenBefore.length) {
      console.log('  skipping: no new viewer');
      return;
    }

    // schedule deletion
    const delaySec = after.selfDestructAfterSeconds || 30;
    const deleteAt = Date.now() + delaySec * 1000;
    console.log(`  scheduling delete in ${delaySec}s (@ ${deleteAt})`);

    await admin
      .firestore()
      .collection('deletionQueue')
      .add({ path, deleteAt });

    console.log('  queued deletion for', path);
  }
);

////////////////////////////////////////////////////////////////////////////////
// 4) Sweep queue every minute (v2 onSchedule)
//    Deletes both the original message and its queue entry
////////////////////////////////////////////////////////////////////////////////
exports.processDeletionQueue = onSchedule(
  {
    region:   'us-central1',
    schedule: 'every 1 minutes',
  },
  async () => {
    const now = Date.now();
    const db  = admin.firestore();

    const snap = await db
      .collection('deletionQueue')
      .where('deleteAt', '<=', now)
      .get();

    if (snap.empty) {
      console.log('processDeletionQueue: nothing to do');
      return;
    }

    const batch = db.batch();
    snap.docs.forEach(doc => {
      const { path } = doc.data();
      console.log('processDeletionQueue: deleting', path);
      batch.delete(db.doc(path));  // remove the secret message
      batch.delete(doc.ref);       // remove the queue record
    });

    await batch.commit();
    console.log('processDeletionQueue: batch committed');
  }
);
