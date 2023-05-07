import * as functions from "firebase-functions";
import { usernameTaken } from "../../utils/username_taken";
import * as admin from "firebase-admin";
import { z } from "zod";
import {
	limStr,
	nameShape,
	storagePathRegExp,
	usernameShape,
} from "../../utils/validators";

const profileUpdateParams = z.object({
	name: z.optional(nameShape),
	username: z.optional(usernameShape),
	pfp: z.optional(
		z.object({
			location: limStr.regex(storagePathRegExp),
			dlUrl: limStr.url(),
		}),
	),
	removeCurrentPfp: z.optional(z.boolean()),
});

export const updateProfile = functions.https.onCall(
	async (
		data: {
			name?: string;
			username?: string;
			pfp?: { location: string; dlUrl: string };
			removeCurrentPfp?: boolean;
		},
		ctx,
	) => {
		if (ctx.auth == null) {
			throw new functions.https.HttpsError(
				"permission-denied",
				MISSING_AUTH_MSG,
			);
		}

		const dataToUpdate: {
			name?: string;
			username?: string;
			pfp?: {
				location: string;
				dlUrl: string;
			} | null;
		} = {};

		const profileUpdateData = profileUpdateParams.parse(data);

		// validate username
		if (profileUpdateData.username != null) {
			const username = profileUpdateData.username.trim();
			if (await usernameTaken(profileUpdateData.username)) {
				throw new functions.https.HttpsError(
					"already-exists",
					`Username ${username} is already taken`,
				);
			} else {
				dataToUpdate.username = username;
			}
		}

		// validate name
		if (profileUpdateData.name != null) {
			dataToUpdate.name = profileUpdateData.name;
		}

		const doc = admin.firestore().collection("users").doc(ctx.auth.uid);

		if (profileUpdateData.removeCurrentPfp === true) {
			dataToUpdate.pfp = null;
			const oldPfpLocation = (await doc.get()).data()?.pfp?.location;
			if (oldPfpLocation != null) {
				const storage = admin.storage();
				await storage.bucket().file(oldPfpLocation).delete();
			}
		}

		if (profileUpdateData.pfp !== null) {
			dataToUpdate.pfp = profileUpdateData.pfp;

			const oldPfpLocation = (await doc.get()).data()?.pfp?.location;
			if (oldPfpLocation != null) {
				const storage = admin.storage();
				await storage.bucket().file(oldPfpLocation).delete();
			}
		}

		await doc.update(dataToUpdate);
	},
);
