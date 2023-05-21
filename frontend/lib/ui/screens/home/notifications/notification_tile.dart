import 'package:flutter/material.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/progress_indicator_button.dart';
import 'package:group_app/utils/max.dart';

enum NotificationType {
  followRequest,
  joinRequest;

  @override
  String toString() {
    switch (this) {
      case NotificationType.followRequest:
        return "Follow request";
      case NotificationType.joinRequest:
        return "Join request";
    }
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile(
      {super.key,
      required this.userRequesting,
      required this.groupRequestedIn,
      required this.notificationType,
      required this.onAccept,
      required this.onDeny});

  final User userRequesting;
  final Group groupRequestedIn;
  final NotificationType notificationType;
  final Future Function() onAccept;
  final Future Function() onDeny;

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(15)),
      width: Max.width(context),
      child: Column(children: [
        Text(
          notificationType.toString(),
          style: const TextStyle(color: Colors.grey),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // user pfp moves left x pixels, so this moves it right again x pixels
                // where x = avatarSize / 2
                const SizedBox(width: avatarSize / 2),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                        left: -(avatarSize / 2),
                        child: BasicCircleAvatar(
                            radius: avatarSize / 2,
                            child: userRequesting.pfp(avatarSize))),
                    Positioned(
                        child: BasicCircleAvatar(
                            radius: avatarSize / 2,
                            child: groupRequestedIn.icon(avatarSize))),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(children: [
                  Text(
                    userRequesting.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        "in ",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      Text(
                        groupRequestedIn.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ]),
              ],
            ),
            Row(
              children: [
                ProgressIndicatorButton(
                  progressIndicatorHeight: 10,
                  progressIndicatorWidth: 10,
                  onPressed: onAccept,
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Colors.white.withOpacity(0.8))),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                ProgressIndicatorButton(
                    progressIndicatorHeight: 10,
                    progressIndicatorWidth: 10,
                    onPressed: onDeny,
                    text: "Deny")
              ],
            )
          ],
        )
      ]),
    );
  }
}
