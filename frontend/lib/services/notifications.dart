import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/request.dart';

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

Future<void> acceptRequest(
    {required String userId,
    required String groupId,
    required RequestType requestType}) async {
  FirebaseFunctions.instance.httpsCallable("acceptRequest").call({
    "userId": userId,
    "groupId": groupId,
    "type": requestType.toString().toLowerCase()
  });
}

Future<void> denyRequest(
    {required String userId,
    required String groupId,
    required RequestType requestType}) async {
  FirebaseFunctions.instance.httpsCallable("denyRequest").call({
    "userId": userId,
    "groupId": groupId,
    "type": requestType.toString().toLowerCase()
  });
}
