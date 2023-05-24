import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/request.dart';
import 'package:group_app/services/notifications.dart';
import 'package:group_app/ui/screens/home/notifications/request_notification_tile.dart';
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
          child: Suspense<List<Request>>(
            future: fetchRequests(fromGroups: currentUser.adminOf),
            builder: (context, requests) {
              if (requests == null) {
                return const Center(
                  child: Text("Something went wrong"),
                );
              }
              if (requests.isEmpty) {
                return const Center(
                  child: Text("Follow and join requests will appear here"),
                );
              }
              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) => RequestNotificationTile(
                  onAccept: () async {
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  onDeny: () async {
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  request: requests[index],
                ),
              );
            },
          )),
    );
  }
}
