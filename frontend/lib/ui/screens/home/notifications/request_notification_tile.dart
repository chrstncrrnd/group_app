import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/request.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/progress_indicator_button.dart';
import 'package:group_app/ui/widgets/suspense.dart';
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

class RequestNotificationTile extends StatelessWidget {
  const RequestNotificationTile(
      {super.key,
      required this.onAccept,
      required this.onDeny,
      required this.request});

  final Request request;

  final Future<void> Function() onAccept;
  final Future<void> Function() onDeny;

  Future<User> _loadUser() async {
    return (await User.fromId(id: request.requester));
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 30;

    return Suspense<User>(
        future: _loadUser(),
        builder: (ctx, data) {
          var user = data!;
          return Card(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "${request.requestType.toString()} request",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  context.push("/user", extra: user);
                                },
                                child: BasicCircleAvatar(
                                    radius: avatarSize / 2,
                                    child: user.pfp(avatarSize))),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              user.username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
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
                ),
              ));
        });
  }
}
