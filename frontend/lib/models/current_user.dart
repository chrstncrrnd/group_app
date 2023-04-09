import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  CurrentUser({
    this.name,
    required this.id,
    required this.username,
  });

  String id;

  String username;
  String? name;

  static Stream<CurrentUser> asStream(String id) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> json) =>
            CurrentUser.fromJson(json.data()!, id));
  }

  static CurrentUser fromJson(Map<String, dynamic> json, String id) {
    return CurrentUser(id: id, username: json["username"], name: json["name"]);
  }
}
