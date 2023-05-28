import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/ui/screens/home/notifications/widgets/group_notifications_tile.dart';
import 'package:group_app/ui/widgets/paginated_streamed_list_view.dart';
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
          child: PaginatedStreamedListView(
            query: FirebaseFirestore.instance
                .collection("groups")
                .where("admins", arrayContains: currentUser.id)
                .where("requestCount", isGreaterThanOrEqualTo: 1)
                .orderBy("requestCount")
                .orderBy("lastChange"),
            pageSize: 10,
            ifEmpty: const Center(
              child:
                  Text("Groups with follow or join requests will appear here"),
            ),
            itemBuilder: (context, item) {
              var json = item.data() as Map<String, dynamic>;
              Group group = Group.fromJson(json: json, id: item.id);
              int requestCount = json["requestCount"];
              return GroupNotificationsTile(
                  group: group, requestCount: requestCount);
            },
          ),
        )
    );
  }
}
