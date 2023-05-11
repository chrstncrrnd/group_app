import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_app/ui/widgets/shimmer_loading_indicator.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser(
      {this.name,
      required this.id,
      required this.username,
      required this.createdAt,
      required this.memberOf,
      required this.following,
      this.pfpDlUrl,
      required this.archivedGroups,
      required this.followRequests,
      required this.joinRequests});

  String id;

  String username;
  String? name;
  String? pfpDlUrl;
  DateTime createdAt;

  List<String> memberOf;
  List<String> following;

  // private data
  List<String> archivedGroups;

  List<String> followRequests;
  List<String> joinRequests;

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

  static Future<CurrentUser> fromJson(
      Map<String, dynamic> json, String id) async {
    var privDataDocData = (await FirebaseFirestore.instance
            .collection("users")
            .doc(id)
            .collection("private_data")
            .doc("private_data")
            .get())
        .data();

    List<String> archGroups = toListString(privDataDocData?["archivedGroups"]);
    List<String> followRequests =
        toListString(privDataDocData?["followRequests"]);
    List<String> joinRequests = toListString(privDataDocData?["joinRequests"]);
    return CurrentUser(
        id: id,
        username: json["username"],
        name: json["name"],
        pfpDlUrl: json["pfp"]?["dlUrl"],
        createdAt: DateTime.parse(json["createdAt"]!),
        following: toListString(json["following"]),
        memberOf: toListString(json["memberOf"]),
        archivedGroups: archGroups,
        joinRequests: joinRequests,
        followRequests: followRequests);
  }

  static Future<CurrentUser> getCurrentUser() async {
    var id = FirebaseAuth.instance.currentUser!.uid;
    var json =
        (await FirebaseFirestore.instance.collection("users").doc(id).get())
            .data();
    return CurrentUser.fromJson(json!, id);
  }

  static Stream<CurrentUser> asStream() {
    var id = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots()
        .asyncMap((event) => CurrentUser.fromJson(event.data()!, id));
  }
}

List<String> toListString(dynamic input) {
  if (input == null) {
    return [];
  }
  return (input as List<dynamic>).map((e) => e.toString()).toList();
}
