import * as functions from 'firebase-functions';
import { z } from 'zod';
import {
  missing_auth_msg,
  user_cannot_react_in_group_msg,
} from '../../utils/constants';
import * as admin from 'firebase-admin';
import { groupModel } from '../../models/group';

const params = z.object({
  groupId: z.string(),
  pageId: z.string(),
  postId: z.string(),
  reaction: z.string(),
});

export const reactToPost = functions.https.onCall(
  async (
    data: {
      groupId: string;
      pageId: string;
      postId: string;
      reaction: string;
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

    const reactorId = ctx.auth.uid;

    const groupDocRef = admin
      .firestore()
      .collection('groups')
      .doc(info.groupId);

    const groupData = groupModel.parse((await groupDocRef.get()).data());

    // Check if the user actually can react.
    // They must be a follower of the group or the group must be public
    const usersThatCanReact = [
      ...groupData.admins,
      ...groupData.followers,
      ...groupData.members,
    ];

    if (!usersThatCanReact.includes(reactorId) && groupData.private) {
      throw new functions.https.HttpsError(
        'permission-denied',
        user_cannot_react_in_group_msg
      );
    }

    const postDocRef = groupDocRef
      .collection('pages')
      .doc(info.pageId)
      .collection('posts')
      .doc(info.postId);

    await postDocRef.set(
      {
        reactions: {
          [reactorId]: [info.reaction],
        },
      },
      { merge: true }
    );
  }
);
