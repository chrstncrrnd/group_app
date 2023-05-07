import * as functions from "firebase-functions";
import { z } from "zod";
import * as admin from "firebase-admin";
import { groupModel, groupPrivateDataModel } from "../../models/group";

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
				followRequests: admin.firestore.FieldValue.arrayUnion([userId]),
			});
			await userDoc.update({
				followRequests: admin.firestore.FieldValue.arrayUnion([d.groupId]),
			});
		} else {
			await groupDoc.update({
				followers: admin.firestore.FieldValue.arrayUnion([userId]),
			});
			await userDoc.update({
				following: admin.firestore.FieldValue.arrayUnion([d.groupId]),
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
				followers: admin.firestore.FieldValue.arrayRemove([userId]),
			});
			await userDoc.update({
				following: admin.firestore.FieldValue.arrayRemove([d.groupId]),
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
				followRequests: admin.firestore.FieldValue.arrayRemove([userId]),
			});
			await userDoc.update({
				followRequests: admin.firestore.FieldValue.arrayRemove([d.groupId]),
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
				joinRequests: admin.firestore.FieldValue.arrayUnion([userId]),
			});
			await userDoc.update({
				joinRequests: admin.firestore.FieldValue.arrayUnion([d.groupId]),
			});
		} else {
			await groupDoc.update({
				members: admin.firestore.FieldValue.arrayUnion([userId]),
			});
			await userDoc.update({
				memberOf: admin.firestore.FieldValue.arrayUnion([d.groupId]),
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
				members: admin.firestore.FieldValue.arrayRemove([userId]),
			});
			await userDoc.update({
				memberOf: admin.firestore.FieldValue.arrayRemove([d.groupId]),
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
				joinRequests: admin.firestore.FieldValue.arrayRemove([userId]),
			});
			await userDoc.update({
				joinRequests: admin.firestore.FieldValue.arrayRemove([d.groupId]),
			});
		}
	},
);
