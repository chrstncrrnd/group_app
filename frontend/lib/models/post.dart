class Post {
  Post.fromJson({required Map<String, dynamic> json, required this.id})
      : createdAt = DateTime.parse(json["createdAt"]),
        creatorId = json["creatorId"],
        dlUrl = json["dlUrl"],
        groupId = json["groupId"],
        pageId = json["pageId"];

  DateTime createdAt;
  String creatorId;
  String dlUrl;
  String groupId;
  String pageId;
  String id;
}
