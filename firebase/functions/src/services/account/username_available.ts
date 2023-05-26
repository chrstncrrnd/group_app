import * as functions from "firebase-functions";
import { usernameTaken } from "../../utils/username_taken";
import { missing_auth_msg } from "../../utils/constants";

export const usernameAvailable = functions.https.onCall(
	async (data: { username: string }, ctx) => {
		if (data.username === null || data.username === undefined) {
			throw new functions.https.HttpsError(
				"invalid-argument",
				missing_auth_msg,
			);
		}
		return !(await usernameTaken(data.username));
	},
);
