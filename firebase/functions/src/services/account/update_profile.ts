import * as functions from 'firebase-functions';
import { usernameTaken } from '../../utils/username_taken';
import * as admin from 'firebase-admin';
import { z } from 'zod';
import {
  limStr,
  nameShape,
  storagePathRegExp,
  usernameShape,
} from '../../utils/validators';
import { missing_auth_msg, username_taken_msg } from '../../utils/constants';

const profileUpdateParams = z.object({
  name: nameShape.nullable().optional(),
  username: usernameShape.optional(),
  pfp: z
    .object({
      location: limStr.regex(storagePathRegExp),
      dlUrl: limStr.url(),
    })
    .nullable()
    .optional(),
});

export const updateProfile = functions.https.onCall(
  async (
    data: {
      name?: string;
      username?: string;
      pfp?: { location: string; dlUrl: string };
    },
    ctx
  ) => {
    if (ctx.auth == null) {
      throw new functions.https.HttpsError(
        'permission-denied',
        missing_auth_msg
      );
    }

    const dataToUpdate: {
      name?: string | null;
      username?: string;
      pfp?: {
        location: string;
        dlUrl: string;
      } | null;
    } = {};

    const profileUpdateData = profileUpdateParams.parse(data);

    // validate username
    if (profileUpdateData.username != null) {
      const username = profileUpdateData.username.trim();
      if (await usernameTaken(profileUpdateData.username)) {
        throw new functions.https.HttpsError(
          'already-exists',
          username_taken_msg
        );
      } else {
        dataToUpdate.username = username;
      }
    }

    dataToUpdate.name = profileUpdateData.name;

    const doc = admin.firestore().collection('users').doc(ctx.auth.uid);

    dataToUpdate.pfp = profileUpdateData.pfp;

    await doc.update(dataToUpdate);
  }
);
