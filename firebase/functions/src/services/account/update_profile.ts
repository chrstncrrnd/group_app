import * as functions from "firebase-functions";
import { validateName, validateUsername } from "../../utils/validators";
import { usernameTaken } from "../../utils/username_taken";
import * as admin from "firebase-admin";

export const updateProfile = functions.https.onCall(
     async (data: {
        name?: string,
        username?: string, 
        pfpLocation?: string, 
        pfpDlUrl?: string
    }, ctx) => {
    if (ctx.auth == null){
        throw new functions.https.HttpsError("permission-denied", "User not signed in");
    }

    const dataToUpdate: any = {};

    // if one is null and the other isn't
    if (typeof data.pfpDlUrl != typeof data.pfpLocation) {
        throw new functions.https.HttpsError("invalid-argument", "Invalid profile picture storage location")
    }
    if (data.pfpDlUrl != null && data.pfpLocation != null) {
        dataToUpdate.pfpDlUrl = data.pfpDlUrl;
        dataToUpdate.pfpLocation = data.pfpLocation;
    }

    // validate username
    if (data.username != null){
        const username = data.username.trim();
        const usernameValid = validateUsername(username);
        if (usernameValid != null){
            throw new functions.https.HttpsError("invalid-argument", usernameValid);
        }
        else if(await usernameTaken(data.username)){
            throw new functions.https.HttpsError("already-exists", `Username ${username} is already taken`);
        }
        else{
            dataToUpdate.username = username;
        }
    }

    // validate name
    if (data.name != null) {
        const nameValid = validateName(data.name);
        if (nameValid != null){
            throw new functions.https.HttpsError("invalid-argument", nameValid);
        }
        dataToUpdate.name = data.name;
    }

    await admin.firestore().collection("users").doc(ctx.auth.uid).update(dataToUpdate);

})