import * as functions from 'firebase-functions';
import {
  missing_auth_msg,
  user_cannot_react_in_group_msg,
} from '../../utils/constants';
import { z } from 'zod';
import { limStr } from '../../utils/validators';
import * as admin from 'firebase-admin';
import { groupModel } from '../../models/group';

const params = z.object({
  groupId: z.string(),
  pageId: z.string(),
  postId: z.string(),
  comment: limStr,
});

export const addComment = functions.https.onCall(
  async (
    data: {
      groupId: string;
      pageId: string;
      postId: string;
      comment: string;
    },
    ctx
  ) => {
    if (ctx.auth == null) {
      throw new functions.https.HttpsError(
        'permission-denied',
        missing_auth_msg
      );
    }

    const info = params.parse(data);

    const commenterId = ctx.auth.uid;

    const groupDoc = admin.firestore().collection('groups').doc(info.groupId);

    const groupData = groupModel.parse((await groupDoc.get()).data());

    const permittedUsers = [
      ...groupData.admins,
      ...groupData.followers,
      ...groupData.members,
    ];

    if (groupData.private && !permittedUsers.includes(commenterId)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        user_cannot_react_in_group_msg
      );
    }

    const postDoc = groupDoc
      .collection('pages')
      .doc(info.pageId)
      .collection('posts')
      .doc(info.postId);

    const commentDoc = postDoc.collection('comments').doc();

    commentDoc.create({
      commenter: commenterId,
      comment: info.comment,
      groupId: info.groupId,
      pageId: info.pageId,
      postId: info.postId,
      createdAt: new Date().toISOString(),
    });
  }
);
