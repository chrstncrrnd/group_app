import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_app/utils/to_list_string.dart';

class Post {
  Post.fromJson({required Map<String, dynamic> json, required this.id})
      : createdAt = DateTime.parse(json["createdAt"]),
        creatorId = json["creatorId"],
        dlUrl = json["dlUrl"],
        groupId = json["groupId"],
        pageId = json["pageId"],
        likes = toListString(json["likes"]),
        caption = json["caption"];

  static Stream<Post> asStream(
          {required String groupId,
          required String pageId,
          required String id}) =>
      FirebaseFirestore.instance
          .collection("groups")
          .doc(groupId)
          .collection("pages")
          .doc(pageId)
          .collection("posts")
          .doc(id)
          .snapshots()
          .map((event) => Post.fromJson(json: event.data()!, id: id));

  DateTime createdAt;
  String creatorId;
  String dlUrl;
  String groupId;
  String pageId;
  String id;
  String? caption;
  List<String> likes;
}
