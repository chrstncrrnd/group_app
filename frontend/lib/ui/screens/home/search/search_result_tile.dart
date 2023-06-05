import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';

enum ResultType { user, group }

class SearchResult extends StatelessWidget {
  const SearchResult(
      {super.key, this.user, this.group, required this.resultType});

  final ResultType resultType;

  final User? user;
  final Group? group;

  @override
  Widget build(BuildContext context) {
    if (resultType == ResultType.user && user == null) {
      return const Text("An error occurred");
    } else if (resultType == ResultType.group && group == null) {
      return const Text("An error occurred");
    }

    const iconRadius = 15.0;

    return Card(
        child: ListTile(
            leading: BasicCircleAvatar(
              radius: iconRadius,
              child: resultType == ResultType.user
                  ? user!.pfp(iconRadius * 2)
                  : group!.icon(iconRadius * 2),
            ),
            title: Text(
                resultType == ResultType.user ? user!.username : group!.name),
            onTap: () => resultType == ResultType.user
                ? context.push("/user", extra: user!)
                : context.push("/group", extra: group!)));
  }
}
