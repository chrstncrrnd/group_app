import * as functions from "firebase-functions";
import { usernameTaken } from "../../utils/username_taken";

export const usernameAvailable = functions.https.onCall(
	async (data: { username: string }, ctx) => {
		if (data.username === null || data.username === undefined) {
			throw new functions.https.HttpsError(
				"invalid-argument",
				MISSING_AUTH_MSG,
			);
		}
		return !(await usernameTaken(data.username));
	},
);
