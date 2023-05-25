import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/notifications.dart';
import 'package:group_app/ui/screens/home/notifications/group_notifications_tile.dart';
import 'package:group_app/ui/widgets/suspense.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CurrentUser currentUser = Provider.of<CurrentUser>(context);

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
          child: Suspense<List<(Group, int)>>(
            future: fetchGroupsWithRequests(userId: currentUser.id),
            builder: (context, data) {
              if (data == null) {
                return const Center(
                  child: Text("Something went wrong"),
                );
              }
              if (data.isEmpty) {
                return const Center(
                  child: Text("Follow and join requests will appear here"),
                );
              }
              return ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                      color: Color.fromARGB(55, 255, 255, 255),
                      endIndent: 10,
                      indent: 10),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var (group, requestCount) = data[index];
                    return GroupNotificationsTile(
                        group: group, requestCount: requestCount);
                  });
            },
          )),
    );
  }
}
