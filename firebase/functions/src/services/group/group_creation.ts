import * as functions from "firebase-functions";
import { validateGroupDescription, validateGroupName } from "../../utils/validators";
import { groupNameTaken } from "../../utils/groupname_taken";
import * as admin from "firebase-admin";

export const createGroup = functions.https.onCall(
    async (data: {groupName: string, groupDescription?: string}, ctx) =>  {
    if (ctx.auth == null){
        throw new functions.https.HttpsError("permission-denied", "User not signed in");
    }

    const groupName = data.groupName.trim();
    const nameValid = validateGroupName(groupName);
    if (nameValid != null){
        throw new functions.https.HttpsError("invalid-argument", nameValid);
    }

    const descriptionValid = validateGroupDescription(data.groupDescription);
    if (descriptionValid != null){
        throw new functions.https.HttpsError("invalid-argument", descriptionValid);
    }

    if(await groupNameTaken(groupName)){
        throw new functions.https.HttpsError("already-exists", `Group name: ${groupName} is already taken`);
    }

    var doc = admin.firestore().collection("groups").doc();
    

    var userId = ctx.auth.uid;

    if (data.groupDescription == null){
        delete data.groupDescription;
    }

    await doc.create({
        name: groupName,
        description: data.groupDescription ?? null,
        createdAt: new Date().toISOString(),
        members: [userId],
        followers: [userId]
    });

    await admin.firestore().collection("users").doc(userId).update({
        memberOf: [doc.id],
        following: [doc.id]
    })
})