import {GoogleGenerativeAI} from '@google/generative-ai';
import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';

initializeApp();

export const askAi = onCall({region: 'asia-southeast2'}, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Login required.');
  }

  const prompt = request.data?.prompt;
  if (typeof prompt !== 'string' || prompt.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'Prompt is required.');
  }

  const snapshot = await getFirestore().doc('aiConfig/gemini').get();
  const apiKey = snapshot.get('apiKey');
  const model = snapshot.get('model') ?? 'gemini-1.5-flash';
  if (typeof apiKey !== 'string' || apiKey.length === 0) {
    throw new HttpsError('failed-precondition', 'AI API key is not configured.');
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  const result = await genAI.getGenerativeModel({model}).generateContent(prompt);

  return {text: result.response.text()};
});
