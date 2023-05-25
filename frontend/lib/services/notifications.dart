import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_app/models/group.dart';

Future<List<(Group group, int requestCount)>> fetchGroupsWithRequests(
    {required String userId}) async {
  List<(Group group, int requestCount)> out = [];

  Query query = FirebaseFirestore.instance
      .collection("groups")
      .where("admins", arrayContains: userId)
      .where("requestCount", isGreaterThanOrEqualTo: 1)
      .orderBy("requestCount")
      .orderBy("lastChange");

  QuerySnapshot querySnapshot = await query.get();

  out.addAll(querySnapshot.docs.map((doc) => (
        Group.fromJson(json: doc.data() as Map<String, dynamic>, id: doc.id),
        doc["requestCount"]
      )));

  return out;
}
