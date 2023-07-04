import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';

class GroupNotificationsTile extends StatelessWidget {
  const GroupNotificationsTile(
      {super.key, required this.group, required this.requestCount});

  final Group group;
  final int requestCount;
  @override
  Widget build(BuildContext context) {
    const double groupIconSize = 40;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.push("/notifications/group", extra: group);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Stack(
                children: [
                  BasicCircleAvatar(
                      radius: groupIconSize / 2,
                      child: group.icon(groupIconSize)),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Badge.count(
                      count: requestCount,
                    ),
                  )
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  group.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              )
            ]),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: groupIconSize / 2,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
