import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/ui/screens/home/notifications/widgets/group_notifications_tile.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CurrentUser currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser!;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Notifications"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("groups")
                  .where("admins", arrayContains: currentUser.id)
                  .where("requestCount", isGreaterThanOrEqualTo: 1)
                  .orderBy("requestCount")
                  .orderBy("lastChange")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(
                    child: Text("Something went wrong..."),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                        "Groups with follow or join requests will appear here"),
                  );
                }
                return ListView.builder(
                  shrinkWrap: false,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var item = snapshot.data!.docs[index];
                    var json = item.data() as Map<String, dynamic>;
                    Group group = Group.fromJson(json: json, id: item.id);
                    int requestCount = json["requestCount"];
                    return GroupNotificationsTile(
                        group: group, requestCount: requestCount);
                  },
                );
              }),
        ));
  }
}
