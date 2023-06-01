import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { groupModel } from '../../models/group';
import { missing_auth_msg, user_not_admin_msg } from '../../utils/constants';

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

    const ref = admin.firestore().collection('groups').doc(data.groupId);
    // delete document
    await admin.firestore().recursiveDelete(ref);
  }
);
