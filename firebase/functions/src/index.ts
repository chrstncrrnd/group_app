import * as admin from "firebase-admin";



export * from "./services/account/create_account";
export * from "./services/group/group_creation";
export * from "./services/account/username_available";

admin.initializeApp();
