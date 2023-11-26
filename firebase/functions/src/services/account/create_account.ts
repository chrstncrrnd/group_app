import * as functions from 'firebase-functions';
import { usernameTaken } from '../../utils/username_taken';
import * as admin from 'firebase-admin';
import { z } from 'zod';
import { nameShape, usernameShape } from '../../utils/validators';
import { missing_auth_msg, username_taken_msg } from '../../utils/constants';

const createAccountParams = z.object({
  username: usernameShape,
  name: nameShape.optional().nullable(),
});

export const createAccount = functions.https.onCall(
  async (data: { name?: string; username: string }, ctx) => {
    if (ctx.auth == null) {
      throw new functions.https.HttpsError(
        'permission-denied',
        missing_auth_msg
      );
    }

    data.username = data.username.trim();

    const d = createAccountParams.parse(data);

    if (await usernameTaken(d.username)) {
      throw new functions.https.HttpsError(
        'already-exists',
        username_taken_msg
      );
    }
    functions.logger.log(ctx.auth.uid);

    const doc = admin.firestore().collection('users').doc(ctx.auth.uid);

    await doc.create({
      name: d.name ?? null,
      username: d.username,
      createdAt: new Date().toISOString(),
      pfp: null,
      following: [],
      memberOf: [],
    });

    // initialize private data
    await doc.collection('private_data').doc('private_data').create({
      followRequests: [],
      joinRequests: [],
    });
  }
);
