class Comment {
  String id;

  String comment;
  String commenterId;
  DateTime createdAt;
  String groupId;
  String pageId;
  String postId;

  Comment.fromJson({required Map<String, dynamic> json, required this.id})
      : comment = json["comment"],
        commenterId = json["commenter"],
        createdAt = DateTime.parse(json["createdAt"]),
        groupId = json["groupId"],
        pageId = json["pageId"],
        postId = json["postId"];
}
