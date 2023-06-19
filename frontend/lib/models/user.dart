import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_app/utils/to_list_string.dart';

import '../ui/widgets/async/shimmer_loading_indicator.dart';


class User {
  User(
      {this.name,
      required this.username,
      required this.id,
      required this.createdAt,
      required this.following,
      required this.memberOf,
      this.pfpDlUrl});

  User.fromJson({required Map<String, dynamic> json, required this.id})
      : name = json["name"],
        username = json["username"],
        createdAt = DateTime.parse(json["createdAt"]),
        following = toListString(json["following"]),
        memberOf = toListString(json["memberOf"]),
        pfpDlUrl = json["pfp"]?["dlUrl"];

  static Future<User> fromId({required String id}) async {
    Map<String, dynamic> data =
        (await FirebaseFirestore.instance.collection("users").doc(id).get())
            .data()!;
    return User.fromJson(json: data, id: id);
  }

  static Stream<User> asStream({required String id}) =>
      FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .snapshots()
          .map((event) => User.fromJson(json: event.data()!, id: id));

  String? name;
  String username;
  String id;
  DateTime createdAt;
  List<String> following;
  List<String> memberOf;
  String? pfpDlUrl;

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

  bool get isNamed => name != null;
}
