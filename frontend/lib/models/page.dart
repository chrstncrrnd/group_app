class GroupPage {
  String id;
  String name;

  String creatorId;
  String groupId;
  DateTime createdAt;

  GroupPage.fromJson({required Map<String, dynamic> json, required this.id})
      : name = json["name"],
        creatorId = json["creatorId"],
        groupId = json["groupId"],
        createdAt = DateTime.parse(json["createdAt"]);
}
