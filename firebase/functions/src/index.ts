import * as admin from "firebase-admin";



export * from "./services/auth/create_account";
export * from "./services/group/group_creation";

admin.initializeApp();
