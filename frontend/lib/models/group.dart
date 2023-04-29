import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../ui/widgets/shimmer_loading_indicator.dart';

class Group {
  Group(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.members,
      required this.followers,
      this.description,
      this.iconDlUrl,
      this.iconLocation});

  Group.fromJson({required Map<String, dynamic> json, required this.id})
      : name = json["name"],
        description = json["description"],
        createdAt = DateTime.parse(json["createdAt"]),
        members = toListString(json["members"]),
        followers = toListString(json["followers"]),
        iconDlUrl = json["iconDlUrl"],
        iconLocation = json["iconLocation"];

  String id;
  String name;
  String? description;
  DateTime createdAt;
  List<String> members;
  List<String> followers;

  String? iconDlUrl;
  String? iconLocation;

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

List<String> toListString(dynamic input) {
  return (input as List<dynamic>).map((e) => e.toString()).toList();
}
