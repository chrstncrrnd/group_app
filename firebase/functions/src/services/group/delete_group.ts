import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { groupModel } from '../../models/group';
import { missing_auth_msg, user_not_admin_msg } from '../../utils/constants';
import { FieldValue } from 'firebase-admin/firestore';

export const deleteGroup = functions.https.onCall(
  async (
    data: {
      groupId: string;
    },
    ctx
  ) => {
    if (ctx.auth == null) {
      throw new functions.https.HttpsError(
        'permission-denied',
        missing_auth_msg
      );
    }
    const groupDocRef = admin
      .firestore()
      .collection('groups')
      .doc(data.groupId);
    const userId = ctx.auth?.uid;

    const groupData = groupModel.parse((await groupDocRef.get()).data());
    if (!groupData.admins.includes(userId)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        user_not_admin_msg
      );
    }

    const fs = admin.firestore();

    const affected = [
      ...groupData.followers,
      ...groupData.members,
      ...groupData.admins,
    ];

    const uniqueAffected = [...new Set(affected)];

    // this is probably really expensive but idk a better way of doing it
    const futures = uniqueAffected.map((userId) =>
      fs
        .collection('users')
        .doc(userId)
        .update({
          following: FieldValue.arrayRemove(data.groupId),
          memberOf: FieldValue.arrayRemove(data.groupId),
          adminOf: FieldValue.arrayRemove(data.groupId),
        })
    );

    await Promise.all(futures);

    const bucket = admin.storage().bucket();
    // directory
    const directoryPath = `groups/${data.groupId}`;
    // List all files in the directory
    const [files] = await bucket.getFiles({ prefix: directoryPath });
    // Delete each file
    const deletePromises = files.map((file) => file.delete());
    // Wait for all files to be deleted
    await Promise.all(deletePromises);
    // Delete the directory itself
    await bucket.deleteFiles({ prefix: directoryPath });

    const ref = fs.collection('groups').doc(data.groupId);
    // delete document
    await fs.recursiveDelete(ref);
  }
);
