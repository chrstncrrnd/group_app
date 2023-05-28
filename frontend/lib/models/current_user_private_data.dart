import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_app/utils/to_list_string.dart';

class CurrentUserPrivateData {
  String id;

  List<String> archivedGroups;

  List<String> followRequests;
  List<String> joinRequests;

  CurrentUserPrivateData.fromJson(
      {required Map<String, dynamic> json, required this.id})
      : archivedGroups = toListString(json["archivedGroups"]),
        followRequests = toListString(json["followRequests"]),
        joinRequests = toListString(json["joinRequests"]);

  static Stream<CurrentUserPrivateData> asStream({required String userId}) =>
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("private_data")
          .doc("private_data")
          .snapshots()
          .map((data) =>
              CurrentUserPrivateData.fromJson(json: data.data()!, id: userId));
}
