import 'package:group_app/models/group.dart';

class GroupPage {
  String id;
  String name;

  String creatorId;
  String groupId;
  DateTime createdAt;
  DateTime lastChange;

  // when it is instantiated, this can be supplied so you don't
  // need to re-fetch the group data, however it should not be used
  // after a long period of time
  Group? cachedGroupData;

  Future<Group> getGroup({bool useCache = true}) async {
    if (cachedGroupData != null && useCache) {
      return cachedGroupData!;
    }
    var g = await Group.fromId(id: id);
    cachedGroupData = g;
    return g;
  }

  GroupPage.fromJson(
      {required Map<String, dynamic> json,
      required this.id,
      this.cachedGroupData})
      : name = json["name"],
        creatorId = json["creatorId"],
        groupId = json["groupId"],
        createdAt = DateTime.parse(json["createdAt"]),
        lastChange = DateTime.parse(json["lastChange"]);
}
