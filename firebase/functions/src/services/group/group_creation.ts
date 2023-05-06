import * as functions from "firebase-functions";
import {
  validateGroupDescription,
  validateGroupName,
} from "../../utils/validators";
import { groupNameTaken } from "../../utils/groupname_taken";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

export const createGroup = functions.https.onCall(
  async (
    data: {
      groupName: string;
      groupDescription?: string;
      iconLocation?: string;
      iconDlUrl?: string;
    },
    ctx
  ) => {
    if (ctx.auth == null) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "User not signed in"
      );
    }

    if (typeof data.iconDlUrl != typeof data.iconLocation) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid icon storage location"
      );
    }

    const groupName = data.groupName.trim();
    const nameValid = validateGroupName(groupName);
    if (nameValid != null) {
      throw new functions.https.HttpsError("invalid-argument", nameValid);
    }

    const descriptionValid = validateGroupDescription(data.groupDescription);
    if (descriptionValid != null) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        descriptionValid
      );
    }

    if (await groupNameTaken(groupName)) {
      throw new functions.https.HttpsError(
        "already-exists",
        `Group name: ${groupName} is already taken`
      );
    }

    const doc = admin.firestore().collection("groups").doc();

    const userId = ctx.auth.uid;

    const docData = {
      name: groupName,
      createdAt: new Date().toISOString(),
      members: [userId],
      followers: [userId],
      description: data.groupDescription ?? null,
      iconDlUrl: data.iconDlUrl ?? null,
      iconLocation: data.iconLocation ?? null,
    };

    await doc.create(docData);

    await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .update({
        memberOf: FieldValue.arrayUnion(doc.id),
        following: FieldValue.arrayUnion(doc.id),
      });
  }
);
