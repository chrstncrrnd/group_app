import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> archiveGroup(String groupId) async {
  FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("private_data")
      .doc("private_data")
      .update({
    "archivedGroups": FieldValue.arrayUnion([groupId])
  });
}
