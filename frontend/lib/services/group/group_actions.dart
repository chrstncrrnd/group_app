import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> archiveGroup(String groupId) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("private_data")
      .doc("private_data")
      .update({
    "archivedGroups": FieldValue.arrayUnion([groupId])
  });
}

Future<void> unArchiveGroup(String groupId) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("private_data")
      .doc("private_data")
      .update({
    "archivedGroups": FieldValue.arrayRemove([groupId])
  });
}

Future<void> followGroup(String groupId) async {
  await FirebaseFunctions.instance
      .httpsCallable("followGroup")
      .call({"groupId": groupId});
}

Future<void> unFollowGroup(String groupId) async {
  await FirebaseFunctions.instance
      .httpsCallable("unFollowGroup")
      .call({"groupId": groupId});
}

Future<void> joinGroup(String groupId) async {
  await FirebaseFunctions.instance
      .httpsCallable("joinGroup")
      .call({"groupId": groupId});
}

Future<void> leaveGroup(String groupId) async {
  await FirebaseFunctions.instance
      .httpsCallable("leaveGroup")
      .call({"groupId": groupId});
}
