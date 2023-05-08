import * as functions from "firebase-functions";
import { z } from "zod";
import * as admin from "firebase-admin";
import { groupModel, groupPrivateDataModel } from "../../models/group";
import { FieldValue } from "firebase-admin/firestore";

const paramsShape = z.object({
	groupId: z.string(),
});

export const followGroup = functions.https.onCall(
	async (data: { groupId: String }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG,
			);
		}

		const d = paramsShape.parse(data);

		const groupDoc = admin.firestore().collection("groups").doc(d.groupId);
		const groupData = groupModel.parse((await groupDoc.get()).data());

		const userId = ctx.auth.uid;

		if (groupData.followers.includes(userId)) {
			return;
		}

		const groupPrivateDataDoc = groupDoc
			.collection("private_data")
			.doc("private_data");

		const groupPrivateData = groupPrivateDataModel.parse(
			(await groupPrivateDataDoc.get()).data(),
		);
		if (groupPrivateData.followRequests?.includes(userId)) {
			return;
		}

		const userDoc = admin
			.firestore()
			.collection("users")
			.doc(userId)
			.collection("private_data")
			.doc("private_data");

		if (groupData.private) {
			await groupPrivateDataDoc.update({
				followRequests: FieldValue.arrayUnion(userId),
			});
			await userDoc.update({
				followRequests: FieldValue.arrayUnion(d.groupId),
			});
		} else {
			await groupDoc.update({
				followers: FieldValue.arrayUnion(userId),
			});
			await userDoc.update({
				following: FieldValue.arrayUnion(d.groupId),
			});
		}
	},
);

export const unFollowGroup = functions.https.onCall(
	async (data: { groupId: String }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG,
			);
		}

		const d = paramsShape.parse(data);

		const userId = ctx.auth.uid;

		const userDoc = admin
			.firestore()
			.collection("users")
			.doc(userId)
			.collection("private_data")
			.doc("private_data");

		// Already a follower
		const groupDoc = admin.firestore().collection("groups").doc(d.groupId);
		const groupData = groupModel.parse((await groupDoc.get()).data());

		if (!groupData.followers.includes(userId)) {
			return;
		} else {
			await groupDoc.update({
				followers: FieldValue.arrayRemove(userId),
				members: FieldValue.arrayRemove(userId),
			});
			await userDoc.update({
				following: FieldValue.arrayRemove(d.groupId),
				memberOf: FieldValue.arrayRemove(d.groupId),
			});
		}

		// Just left a follow request
		const groupPrivateDataDoc = groupDoc
			.collection("private_data")
			.doc("private_data");

		const groupPrivateData = groupPrivateDataModel.parse(
			(await groupPrivateDataDoc.get()).data(),
		);
		if (!groupPrivateData.followRequests?.includes(userId)) {
			return;
		} else {
			await groupPrivateDataDoc.update({
				followRequests: FieldValue.arrayRemove(userId),
			});
			await userDoc.update({
				followRequests: FieldValue.arrayRemove(d.groupId),
			});
		}
	},
);

export const joinGroup = functions.https.onCall(
	async (data: { groupId: String }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG,
			);
		}

		const d = paramsShape.parse(data);

		const groupDoc = admin.firestore().collection("groups").doc(d.groupId);
		const groupData = groupModel.parse((await groupDoc.get()).data());

		const userId = ctx.auth.uid;

		if (groupData.members.includes(userId)) {
			return;
		}

		const groupPrivateDataDoc = groupDoc
			.collection("private_data")
			.doc("private_data");

		const groupPrivateData = groupPrivateDataModel.parse(
			(await groupPrivateDataDoc.get()).data(),
		);
		if (groupPrivateData.joinRequests?.includes(userId)) {
			return;
		}

		const userDoc = admin
			.firestore()
			.collection("users")
			.doc(userId)
			.collection("private_data")
			.doc("private_data");

		if (groupData.private) {
			await groupPrivateDataDoc.update({
				joinRequests: FieldValue.arrayUnion(userId),
			});
			await userDoc.update({
				joinRequests: FieldValue.arrayUnion(d.groupId),
			});
		} else {
			await groupDoc.update({
				members: FieldValue.arrayUnion(userId),
				followers: FieldValue.arrayUnion(userId),
			});
			await userDoc.update({
				memberOf: FieldValue.arrayUnion(d.groupId),
				following: FieldValue.arrayUnion(d.groupId),
			});
		}
	},
);

export const leaveGroup = functions.https.onCall(
	async (data: { groupId: String }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG,
			);
		}

		const d = paramsShape.parse(data);

		const userId = ctx.auth.uid;

		const userDoc = admin
			.firestore()
			.collection("users")
			.doc(userId)
			.collection("private_data")
			.doc("private_data");

		// Already a member
		const groupDoc = admin.firestore().collection("groups").doc(d.groupId);
		const groupData = groupModel.parse((await groupDoc.get()).data());

		if (!groupData.members.includes(userId)) {
			return;
		} else {
			await groupDoc.update({
				members: FieldValue.arrayRemove(userId),
			});
			await userDoc.update({
				memberOf: FieldValue.arrayRemove(d.groupId),
			});
		}

		// Just left a join request
		const groupPrivateDataDoc = groupDoc
			.collection("private_data")
			.doc("private_data");

		const groupPrivateData = groupPrivateDataModel.parse(
			(await groupPrivateDataDoc.get()).data(),
		);
		if (!groupPrivateData.joinRequests?.includes(userId)) {
			return;
		} else {
			await groupPrivateDataDoc.update({
				joinRequests: FieldValue.arrayRemove(userId),
			});
			await userDoc.update({
				joinRequests: FieldValue.arrayRemove(d.groupId),
			});
		}
	},
);
