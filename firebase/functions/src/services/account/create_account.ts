import * as functions from "firebase-functions";
import { usernameTaken } from "../../utils/username_taken";
import * as admin from "firebase-admin";
import { z } from "zod";
import { nameShape, usernameShape } from "../../utils/validators";

const createAccountParams = z.object({
	username: usernameShape,
	name: z.optional(nameShape),
});

export const createAccount = functions.https.onCall(
	async (data: { name?: string; username: string }, ctx) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				missing_auth_msg,
			);
		}

		const d = createAccountParams.parse(data);

		const username = d.username.trim();

		if (await usernameTaken(d.username)) {
			throw new functions.https.HttpsError(
				"already-exists",
				username_taken_msg,
			);
		}
		functions.logger.log(ctx.auth.uid);

		const doc = admin.firestore().collection("users").doc(ctx.auth.uid);

		await doc.create({
			name: d.name ?? null,
			username: username,
			createdAt: new Date().toISOString(),
			pfp: {
				dlUrl: null,
				location: null,
			},
			following: [],
			memberOf: [],
		});

		// initialize private data
		await doc.collection("private_data").doc("private_data").create({
			archivedGroups: null,
		});
	},
);
