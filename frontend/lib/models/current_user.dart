
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_app/ui/widgets/async/shimmer_loading_indicator.dart';
import 'package:group_app/utils/to_list_string.dart';

class CurrentUser {
  CurrentUser({
    this.name,
    required this.id,
    required this.username,
    required this.createdAt,
    required this.memberOf,
    required this.following,
    required this.adminOf,
    this.pfpDlUrl,
  });

  String id;

  String username;
  String? name;
  String? pfpDlUrl;
  DateTime createdAt;

  List<String> memberOf;
  List<String> following;
  List<String> adminOf;

  Widget pfp(double size) => pfpDlUrl == null
      ? Icon(
          Icons.person,
          color: Colors.white,
          size: size / 1.5,
        )
      : CachedNetworkImage(
          width: size,
          height: size,
          imageUrl: pfpDlUrl!,
          placeholder: (context, url) {
            return ShimmerLoadingIndicator(
              width: size,
              height: size,
              borderRadius: BorderRadius.circular(size),
            );
          },
        );

  static CurrentUser fromJson(Map<String, dynamic> json, String id) {
    return CurrentUser(
        id: id,
        username: json["username"],
        name: json["name"],
        pfpDlUrl: json["pfp"]?["dlUrl"],
        createdAt: DateTime.parse(json["createdAt"]!),
        following: toListString(json["following"]),
        memberOf: toListString(json["memberOf"]),
        adminOf: toListString(json["adminOf"]));
  }

  static Future<CurrentUser> getCurrentUser() async {
    var id = FirebaseAuth.instance.currentUser!.uid;
    var json =
        (await FirebaseFirestore.instance.collection("users").doc(id).get())
            .data();
    return CurrentUser.fromJson(json!, id);
  }

  static Stream<CurrentUser> asStream({required String id}) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots()
        .map((event) => CurrentUser.fromJson(event.data()!, id));
  }
}
