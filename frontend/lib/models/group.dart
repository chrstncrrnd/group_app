import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_app/ui/widgets/async/shimmer_loading_indicator.dart';
import 'package:group_app/utils/to_list_string.dart';


class Group {
  Group(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.members,
      required this.followers,
      required this.private,
      required this.admins,
      this.description,
      this.iconDlUrl,
      this.iconLocation,
      this.bannerDlUrl,
      this.bannerLocation});

  Group.fromJson({required Map<String, dynamic> json, required this.id})
      : name = json["name"],
        description = json["description"],
        createdAt = DateTime.parse(json["createdAt"]),
        members = toListString(json["members"]),
        admins = toListString(json["admins"]),
        followers = toListString(json["followers"]),
        iconDlUrl = json["icon"]?["dlUrl"],
        iconLocation = json["icon"]?["location"],
        bannerDlUrl = json["banner"]?["dlUrl"],
        bannerLocation = json["banner"]?["location"],
        private = json["private"];

  static Future<Group> fromId({required String id}) async {
    Map<String, dynamic> data =
        (await FirebaseFirestore.instance.collection("groups").doc(id).get())
            .data()!;
    return Group.fromJson(json: data, id: id);
  }

  String id;
  String name;
  String? description;
  DateTime createdAt;
  List<String> members;
  List<String> followers;
  List<String> admins;

  bool private;

  String? iconDlUrl;
  String? iconLocation;

  String? bannerDlUrl;
  String? bannerLocation;

  static Stream<Group> asStream({required String id}) =>
      FirebaseFirestore.instance
          .collection("groups")
          .doc(id)
          .snapshots()
          .map((event) => Group.fromJson(json: event.data()!, id: id));

  Widget icon(double size) => iconDlUrl == null
      ? Icon(
          Icons.group,
          color: Colors.white,
          size: size / 1.5,
        )
      : CachedNetworkImage(
          width: size,
          height: size,
          imageUrl: iconDlUrl!,
          placeholder: (context, url) {
            return ShimmerLoadingIndicator(
              width: size,
              height: size,
              borderRadius: BorderRadius.circular(size),
            );
          },
        );
}
