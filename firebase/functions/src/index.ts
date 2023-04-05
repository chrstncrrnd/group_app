import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
export * from "./auth/create_account";

admin.initializeApp();


export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});
