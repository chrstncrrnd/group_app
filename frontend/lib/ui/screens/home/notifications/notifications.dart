import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/screens/home/notifications/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // just temp for development
    final Group fakeGroup = Group(
        id: "group",
        name: "fake_group",
        createdAt: DateTime.now(),
        members: ["user"],
        followers: ["user"],
        private: false);

    final User fakeUser = User(
      createdAt: DateTime.now(),
      following: ["group"],
      memberOf: ["group"],
      id: "user",
      username: "username",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          NotificationTile(
            groupRequestedIn: fakeGroup,
            userRequesting: fakeUser,
            notificationType: NotificationType.followRequest,
            onAccept: () async {
              await Future.delayed(const Duration(seconds: 1));
              print("accepted");
            },
            onDeny: () async {
              await Future.delayed(const Duration(seconds: 1));
              print("denied");
            },
          ),
          const SizedBox(
            height: 10,
          ),
          NotificationTile(
            groupRequestedIn: fakeGroup,
            userRequesting: fakeUser,
            notificationType: NotificationType.joinRequest,
            onAccept: () async {
              await Future.delayed(const Duration(seconds: 1));
              print("accepted");
            },
            onDeny: () async => print("denied"),
          )
        ]),
      ),
    );
  }
}
