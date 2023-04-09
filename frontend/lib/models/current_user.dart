import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser(
      {this.name,
      required this.id,
      required this.username,
      required this.createdAt});

  String id;

  String username;
  String? name;
  String? pfpUrl;
  DateTime createdAt;

  Widget pfp(double size) => pfpUrl == null
      ? Icon(
          Icons.person,
          color: Colors.white,
          size: size,
        )
      : CachedNetworkImage(
          width: size,
          height: size,
          imageUrl: pfpUrl!,
          placeholder: (context, url) {
            return const CircularProgressIndicator.adaptive();
          },
        );

  void listenForChanges() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots()
        .listen((newData) {
      var json = newData.data();
      print("JSON: " + json.toString());
      if (json != null) {
        updateCurrentUser(json);
      }
      notifyListeners();
    });
  }

  void updateCurrentUser(Map<String, dynamic> json) {
    // only updatable fields (stuff like createdAt and id should not be changed)
    username = json["username"];
    name = json["name"];
    pfpUrl = json["pfpUrl"];
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
