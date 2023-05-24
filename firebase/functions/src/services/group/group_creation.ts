import * as functions from "firebase-functions";
import { groupNameTaken } from "../../utils/groupname_taken";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import { z } from "zod";
import {
	groupDescriptionShape,
	groupNameShape,
	limStr,
	storagePathRegExp,
} from "../../utils/validators";

const createGroupParams = z.object({
	groupName: groupNameShape,
	groupDescription: z.optional(groupDescriptionShape),
	icon: z.optional(
		z.object({
			location: limStr.regex(storagePathRegExp),
			dlUrl: limStr.url(),
		}),
	),
});

export const createGroup = functions.https.onCall(
	async (
		data: {
			groupName: string;
			groupDescription?: string;
			icon?: {
				location: string;
				dlUrl: string;
			};
		},
		ctx,
	) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG,
			);
		}

		const d = createGroupParams.parse(data);

		const groupName = d.groupName.trim();

		if (await groupNameTaken(groupName)) {
			throw new functions.https.HttpsError(
				"already-exists",
				GROUP_NAME_TAKEN_MSG,
			);
		}

		const userId = ctx.auth.uid;

		const doc = admin.firestore().collection("groups").doc();

		const docData = {
			name: groupName,
			createdAt: new Date().toISOString(),
			members: [userId],
			followers: [userId],
			admins: [userId],
			description: d.groupDescription ?? null,
			icon: d.icon ?? null,
			banner: null,
			private: false,
		};

		await doc.create(docData);

		await admin
			.firestore()
			.collection("users")
			.doc(userId)
			.update({
				memberOf: FieldValue.arrayUnion(doc.id),
				following: FieldValue.arrayUnion(doc.id),
				adminOf: FieldValue.arrayUnion(doc.id),
			});
	},
);
