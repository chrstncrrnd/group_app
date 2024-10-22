import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

export * from './services/account/create_account';
export * from './services/group/group_creation';
export * from './services/account/username_available';
export * from './services/account/update_profile';
export * from './services/group/user_group_base_interactions';
export * from './services/group/update_group';
export * from './services/group/delete_group';
export * from './services/posts/post';
export * from './services/posts/post_like';
export * from './services/posts/add_comment';

admin.initializeApp();
admin.firestore().settings({ ignoreUndefinedProperties: true });


export const ping = functions.https.onCall(async () => {
  return 'Pong!';
});
  