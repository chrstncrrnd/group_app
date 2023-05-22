import * as functions from "firebase-functions";
import { z } from "zod";
import * as admin from "firebase-admin";
import { groupModel } from "../../models/group";
import { FieldValue } from "firebase-admin/firestore";

const paramsShape = z.object({
	groupId: z.string(),
});

const createRequest = async (data: {
	type: "follow" | "join";
	userId: string;
	groupId: string;
}): Promise<"success" | "failure"> => {
	const fs = admin.firestore();

	const groupData = groupModel.parse(
		(await fs.collection("groups").doc(data.groupId).get()).data()
	);
	if (data.type == "follow" && groupData.followers.includes(data.userId)) {
		return "failure";
	}
	if (data.type == "join" && groupData.members.includes(data.groupId)) {
		return "failure";
	}

	const reqDoc = fs
		.collection("groups")
		.doc(data.groupId)
		.collection("requests")
		.doc(`${data.userId}:${data.type}`);

	// update group
	try {
		await reqDoc.create({
			type: data.type,
			userId: data.userId,
			createdAt: new Date().toISOString(),
		});
	} catch {
		return "failure";
	}

	const userPrivDoc = fs
		.collection("users")
		.doc(data.userId)
		.collection("private_data")
		.doc("private_data");

	// update user
	const updateData: {
		followRequests?: FieldValue;
		joinRequests?: FieldValue;
	} = {};

	if (data.type == "follow") {
		updateData.followRequests = FieldValue.arrayUnion(data.groupId);
	} else {
		updateData.joinRequests = FieldValue.arrayUnion(data.groupId);
	}
	await userPrivDoc.update(updateData);
	return "success";
};

const deleteRequest = async (data: {
	type: "follow" | "join";
	userId: string;
	groupId: string;
}) => {
	const fs = admin.firestore();

	const reqDoc = fs
		.collection("groups")
		.doc(data.groupId)
		.collection("requests")
		.doc(`${data.userId}:${data.type}`);

	// update group
	await reqDoc.delete();

	const userPrivDoc = fs
		.collection("users")
		.doc(data.userId)
		.collection("private_data")
		.doc("private_data");

	// update user
	const updateData: {
		followRequests?: FieldValue;
		joinRequests?: FieldValue;
	} = {};

	if (data.type == "follow") {
		updateData.followRequests = FieldValue.arrayRemove(data.groupId);
	} else {
		updateData.joinRequests = FieldValue.arrayRemove(data.groupId);
	}
	await userPrivDoc.update(updateData);
};

export const followGroup = functions.https.onCall(
	async (data: { groupId: string }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG
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
		if (groupData.private) {
			await createRequest({
				type: "follow",
				userId: userId,
				groupId: d.groupId,
			});
		} else {
			await groupDoc.update({ followers: FieldValue.arrayUnion(userId) });
		}
	}
);

export const unFollowGroup = functions.https.onCall(
	async (data: { groupId: string }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG
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
		// also delete the request
		await deleteRequest({
			type: "follow",
			userId: ctx.auth.uid,
			groupId: d.groupId,
		});
	}
);

export const joinGroup = functions.https.onCall(
	async (data: { groupId: string }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG
			);
		}

		const d = paramsShape.parse(data);

		await createRequest({
			type: "join",
			groupId: d.groupId,
			userId: ctx.auth.uid,
		});
	}
);

export const leaveGroup = functions.https.onCall(
	async (data: { groupId: string }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG
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

		await deleteRequest({ type: "join", groupId: d.groupId, userId: userId });
	}
);
