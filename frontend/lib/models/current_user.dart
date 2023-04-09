import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser(
      {this.name,
      required this.id,
      required this.username,
      required this.createdAt});

  String id;

  String username;
  String? name;
  DateTime createdAt;

  void listenForChanges() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots()
        .listen((newData) {
      var json = newData.data();
      if (json != null) {
        updateCurrentUser(json);
      }
    });
  }

  void updateCurrentUser(Map<String, dynamic> json) {
    // only updatable fields (stuff like createdAt and id should not be changed)
    username = json["username"];
    name = json["name"];
    notifyListeners();
  }

  static Future<CurrentUser> fromId(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection("users").doc(id).get();
    return CurrentUser.fromJson(doc.data()!, id);
  }

  static CurrentUser fromJson(Map<String, dynamic> json, String id) {
    return CurrentUser(
        id: id,
        username: json["username"],
        name: json["name"],
        createdAt: DateTime.parse(json["createdAt"]!));
  }
}
