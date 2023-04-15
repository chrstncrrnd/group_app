class Group {
  Group(
      {required this.name,
      required this.createdAt,
      required this.members,
      required this.followers,
      this.description});

  Group.fromJson({required Map<String, dynamic> json})
      : name = json["name"],
        description = json["description"],
        createdAt = DateTime.parse(json["createdAt"]),
        members = toListString(json["members"]),
        followers = toListString(json["followers"]);

  String name;
  String? description;
  DateTime createdAt;
  List<String> members;
  List<String> followers;
}

List<String> toListString(dynamic input) {
  return (input as List<dynamic>).map((e) => e.toString()).toList();
}
