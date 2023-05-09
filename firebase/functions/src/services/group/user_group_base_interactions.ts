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

		// parse group data
		const groupDoc = admin.firestore().collection("groups").doc(d.groupId);
		const groupData = groupModel.parse((await groupDoc.get()).data());

		const userId = ctx.auth.uid;

		// if the group followers already has this user, return
		if (groupData.followers.includes(userId)) {
			return;
		}

		const groupPrivateDataDoc = groupDoc
			.collection("private_data")
			.doc("private_data");

		const groupPrivateData = groupPrivateDataModel.parse(
			(await groupPrivateDataDoc.get()).data(),
		);
		// if they already sent a follow request, return
		if (groupPrivateData.followRequests?.includes(userId)) {
			return;
		}

		const userDoc = admin.firestore().collection("users").doc(userId);

		const userPrivDoc = userDoc.collection("private_data").doc("private_data");

		// if the group is private, just send a request
		if (groupData.private) {
			await groupPrivateDataDoc.update({
				followRequests: FieldValue.arrayUnion(userId),
			});
			await userPrivDoc.update({
				followRequests: FieldValue.arrayUnion(d.groupId),
			});
		}
		// if its not private, add yourself directly to followers
		else {
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

		const userDoc = admin.firestore().collection("users").doc(userId);

		// Parse group data
		const groupDoc = admin.firestore().collection("groups").doc(d.groupId);
		const groupData = groupModel.parse((await groupDoc.get()).data());

		// if user is follower
		if (groupData.followers.includes(userId)) {
			// remove user from followers on that group
			await groupDoc.update({
				followers: FieldValue.arrayRemove(userId),
				// if a member of a group un follows that group,
				// they also leave the group (len(followers) >= len(members))
				members: FieldValue.arrayRemove(userId),
			});
			// remove group from self following
			await userDoc.update({
				following: FieldValue.arrayRemove(d.groupId),
				memberOf: FieldValue.arrayRemove(d.groupId),
			});
		}

		const userPrivDoc = userDoc.collection("private_data").doc("private_data");

		// Just left a follow request
		const groupPrivateDataDoc = groupDoc
			.collection("private_data")
			.doc("private_data");

		const groupPrivateData = groupPrivateDataModel.parse(
			(await groupPrivateDataDoc.get()).data(),
		);
		// if the user just left a follow request
		if (groupPrivateData.followRequests?.includes(userId)) {
			await groupPrivateDataDoc.update({
				followRequests: FieldValue.arrayRemove(userId),
			});
			await userPrivDoc.update({
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

		// parse group data
		const groupDoc = admin.firestore().collection("groups").doc(d.groupId);
		const groupData = groupModel.parse((await groupDoc.get()).data());

		const userId = ctx.auth.uid;

		// if user is not a member, return
		if (groupData.members.includes(userId)) {
			return;
		}

		const groupPrivateDataDoc = groupDoc
			.collection("private_data")
			.doc("private_data");

		const groupPrivateData = groupPrivateDataModel.parse(
			(await groupPrivateDataDoc.get()).data(),
		);
		// if user already requested, return
		if (groupPrivateData.joinRequests?.includes(userId)) {
			return;
		}

		const userPrivDoc = admin
			.firestore()
			.collection("users")
			.doc(userId)
			.collection("private_data")
			.doc("private_data");

		// joins always need to be approved
		await groupPrivateDataDoc.update({
			joinRequests: FieldValue.arrayUnion(userId),
		});
		await userPrivDoc.update({
			joinRequests: FieldValue.arrayUnion(d.groupId),
		});
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

		const userDoc = admin.firestore().collection("users").doc(userId);
		const userPrivDoc = userDoc.collection("private_data").doc("private_data");

		const groupDoc = admin.firestore().collection("groups").doc(d.groupId);
		const groupData = groupModel.parse((await groupDoc.get()).data());

		// if you are a member, remove the stuff
		if (groupData.members.includes(userId)) {
			await groupDoc.update({
				members: FieldValue.arrayRemove(userId),
			});
			await userDoc.update({
				memberOf: FieldValue.arrayRemove(d.groupId),
			});
			await userPrivDoc.update({
				archivedGroups: FieldValue.arrayRemove(d.groupId),
			});
		}

		// Just left a join request
		const groupPrivateDataDoc = groupDoc
			.collection("private_data")
			.doc("private_data");

		const groupPrivateData = groupPrivateDataModel.parse(
			(await groupPrivateDataDoc.get()).data(),
		);
		if (groupPrivateData.joinRequests?.includes(userId)) {
			await groupPrivateDataDoc.update({
				joinRequests: FieldValue.arrayRemove(userId),
			});
			await userPrivDoc.update({
				joinRequests: FieldValue.arrayRemove(d.groupId),
			});
		}
	},
);
