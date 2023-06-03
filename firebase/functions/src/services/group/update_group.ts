import * as functions from 'firebase-functions';
import { z } from 'zod';
import { groupDescriptionShape, groupNameShape } from '../../utils/validators';
import { storagePathRegExp } from '../../utils/validators';
import * as admin from 'firebase-admin';
import { groupModel } from '../../models/group';
import { missing_auth_msg, user_not_admin_msg } from '../../utils/constants';
import { FieldValue } from 'firebase-admin/firestore';

const updateGroupParams = z.object({
  groupId: z.string(),
  groupName: groupNameShape.optional(),
  groupDescription: groupDescriptionShape.optional().nullable(),
  private: z.boolean().optional(),
  icon: z
    .object({
      location: z.string().regex(storagePathRegExp),
      dlUrl: z.string().url(),
    })
    .nullable()
    .optional(),
  banner: z
    .object({
      location: z.string().regex(storagePathRegExp),
      dlUrl: z.string().url(),
    })
    .nullable()
    .optional(),
});

export const updateGroup = functions.https.onCall(
  async (
    data: {
      groupId: string;
      groupName?: string;
      groupDescription?: string;
      private?: boolean;
      icon?: {
        location: string;
        dlUrl: string;
      };
      banner?: {
        location: string;
        dlUrl: string;
      };
    },
    ctx
  ) => {
    if (ctx.auth == null) {
      throw new functions.https.HttpsError(
        'permission-denied',
        missing_auth_msg
      );
    }
    const d = updateGroupParams.parse(data);
    const groupDocRef = admin.firestore().collection('groups').doc(d.groupId);
    const userId = ctx.auth?.uid;

    const groupData = groupModel.parse((await groupDocRef.get()).data());
    if (!groupData.admins.includes(userId)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        user_not_admin_msg
      );
    }

    if (d.groupDescription?.length === 0) {
      d.groupDescription = null;
    }

    await groupDocRef.update({
      name: d.groupName,
      description: d.groupDescription,
      banner: d.banner,
      icon: d.icon,
      private: d.private,
      lastChange: new Date().toISOString(),
    });
  }
);

const removeUserParams = z.object({
  userId: z.string(),
  groupId: z.string(),
  as: z.union([z.literal('follower'), z.literal('member')]),
});

export const removeUserFromGroup = functions.https.onCall(
  async (
    data: {
      userId: string;
      groupId: string;
      as: 'follower' | 'member';
    },
    ctx
  ) => {
    if (ctx.auth == null) {
      throw new functions.https.HttpsError(
        'permission-denied',
        missing_auth_msg
      );
    }
    const d = removeUserParams.parse(data);

    const groupDoc = admin.firestore().collection('groups').doc(d.groupId);

    const group = groupModel.parse((await groupDoc.get()).data());
    if (!group.admins.includes(ctx.auth.uid)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        user_not_admin_msg
      );
    }

    const groupUpdateData: { followers?: FieldValue; members?: FieldValue } =
      {};

    const userUpdateData: { following?: FieldValue; memberOf?: FieldValue } =
      {};

    if (d.as == 'follower') {
      groupUpdateData.followers = FieldValue.arrayRemove(d.userId);
      userUpdateData.following = FieldValue.arrayRemove(d.groupId);
    } else {
      groupUpdateData.members = FieldValue.arrayRemove(d.userId);
      userUpdateData.memberOf = FieldValue.arrayRemove(d.groupId);
    }

    await groupDoc.update(groupUpdateData);
    const userDoc = admin.firestore().collection('users').doc(d.userId);
    await userDoc.update(userUpdateData);
  }
);
