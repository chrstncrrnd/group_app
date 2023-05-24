import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_app/models/request.dart';

Future<List<Request>> fetchRequests({required List<String> fromGroups}) async {
  List<Request> requests = [];

  for (String g in fromGroups) {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("groups")
        .doc(g)
        .collection("requests")
        .get();
    requests.addAll(querySnapshot.docs.map(
        (e) => Request.fromJson(json: (e.data() as Map<String, dynamic>))));
  }

  return requests;
}
