import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { z } from 'zod';
import { storagePathRegExp } from '../../utils/validators';
import {
  missing_auth_msg,
  user_cannot_post_in_group_msg,
} from '../../utils/constants';
import { groupModel } from '../../models/group';
import { FieldValue } from 'firebase-admin/firestore';

const createPostParams = z.object({
  dlUrl: z.string(),
  location: z.string().regex(storagePathRegExp),
  id: z.string().length(20),
  groupId: z.string(),
  pageId: z.string(),
});

export const createPost = functions.https.onCall(
  async (
    data: {
      dlUrl: string;
      location: string;
      id: string;
      groupId: string;
      pageId: string;
    },
    ctx
  ) => {
    if (ctx.auth == null) {
      throw new functions.https.HttpsError(
        'permission-denied',
        missing_auth_msg
      );
    }

    const userId = ctx.auth.uid;

    const d = createPostParams.parse(data);

    const groupRef = admin.firestore().collection('groups').doc(d.groupId);
    const groupData = groupModel.parse((await groupRef.get()).data());

    // members and admins
    const usersAllowedToPost = [
      ...new Set([...groupData.admins, ...groupData.members]),
    ];

    if (!usersAllowedToPost.includes(userId)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        user_cannot_post_in_group_msg
      );
    }

    const pageRef = groupRef.collection('pages').doc(d.pageId);
    const postRef = pageRef.collection('posts').doc(d.id);
    const now = new Date().toISOString();

    await postRef.create({
      groupId: d.groupId,
      creatorId: userId,
      pageId: d.pageId,
      dlUrl: d.dlUrl,
      storageLocation: d.location,
      createdAt: now,
    });

    await pageRef.update({
      contributors: FieldValue.arrayUnion(userId),
      lastChange: now,
    });
  }
);
