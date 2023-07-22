import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/async/suspense.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';

enum UserAffiliatedGroupsType {
  memberOf,
  following;

  String getTitle() {
    switch (this) {
      case UserAffiliatedGroupsType.memberOf:
        return "Member of";
      case UserAffiliatedGroupsType.following:
        return "Following";
    }
  }
}

class UserAffiliatedGroups extends StatelessWidget {
  const UserAffiliatedGroups(
      {super.key, required this.type, required this.user});

  final UserAffiliatedGroupsType type;
  final User user;

  @override
  Widget build(BuildContext context) {
    const iconSize = 23.0;

    final groups = type == UserAffiliatedGroupsType.memberOf
        ? user.memberOf
        : user.following;

    return Scaffold(
      appBar: AppBar(
        title: Text(type.getTitle()),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return Suspense<Group>(
              future: Group.fromId(id: groups[index]),
              builder: (context, data) {
                Group group = data!;
                return ListTile(
                  onTap: () => context.push("/group", extra: group),
                  title: AutoSizeText(
                    group.name,
                    minFontSize: 11,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 17),
                  ),
                  subtitle: group.description != null
                      ? Text(
                          group.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  leading: BasicCircleAvatar(
                      radius: iconSize, child: group.icon(iconSize * 2)),
                );
              }
          );
        },
      ),
    );
  }
}
