import * as admin from "firebase-admin";

export async function usernameTaken(username: string): Promise<boolean>  {
    let count = (await admin
        .firestore()
        .collection("users")
        .where("username", "==", username)
        .count()
        .get())
        .data()
        .count;

    return count > 0;
}