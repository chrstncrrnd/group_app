import * as functions from "firebase-functions";
import { validateName, validateUsername } from "../../utils/validators";
import { usernameTaken } from "../../utils/username_taken";
import * as admin from "firebase-admin";

export const createAccount = functions.https.onCall(
     async (data: {name?: string, username: string}, ctx) => {
    if (ctx.auth == null){
        throw new functions.https.HttpsError("permission-denied", "User not signed in");
    }

    const username = data.username.trim();

    // validate username
    const usernameValid = validateUsername(username);
    if (usernameValid != null){
        throw new functions.https.HttpsError("invalid-argument", usernameValid);
    }

    // validate name
    const nameValid = validateName(data.name);
    if (nameValid != null){
        throw new functions.https.HttpsError("invalid-argument", nameValid);
    }

    if(await usernameTaken(data.username)){
        throw new functions.https.HttpsError("already-exists", `Username ${username} is already taken`);
    }

    await admin.firestore().collection("users").doc(ctx.auth.uid).create({
        name: data.name ?? null,
        username: username,
        createdAt: new Date().toISOString(),
        following: [],
        memberof: []
    });

})