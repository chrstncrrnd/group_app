import * as admin from 'firebase-admin';

export async function groupNameTaken(groupName: string): Promise<boolean> {
  const count = (
    await admin
      .firestore()
      .collection('groups')
      .where('name', '==', groupName)
      .count()
      .get()
  ).data().count;

  return count > 0;
}
