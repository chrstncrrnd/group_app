import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  static CurrentUser fromJson(Map<String, dynamic> json, String id) {
    return CurrentUser(
        id: id,
        username: json["username"],
        name: json["name"],
        createdAt: DateTime.parse(json["createdAt"]!));
  }

  static Stream<CurrentUser> asStream() {
    var id = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots()
        .map((event) => CurrentUser.fromJson(event.data()!, id));
  }
}
