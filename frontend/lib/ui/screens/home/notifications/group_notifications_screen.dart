import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/request.dart';
import 'package:groopo/services/notifications.dart';
import 'package:groopo/ui/screens/home/notifications/widgets/request_notification_tile.dart';

class GroupNotificationScreen extends StatefulWidget {
  const GroupNotificationScreen({super.key, required this.group});
  final Group group;

  @override
  State<GroupNotificationScreen> createState() =>
      _GroupNotificationScreenState();
}

class _GroupNotificationScreenState extends State<GroupNotificationScreen> {
  Future<void> _onAccept(
      {required String groupId,
      required String userId,
      required RequestType requestType}) async {
    await acceptRequest(
        userId: userId, groupId: groupId, requestType: requestType);
  }

  Future<void> _onDeny(
      {required String groupId,
      required String userId,
      required RequestType requestType}) async {
    await denyRequest(
        userId: userId, groupId: groupId, requestType: requestType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                context.push("/group", extra: widget.group);
              },
              child: Text(widget.group.name),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("groups")
              .doc(widget.group.id)
              .collection("requests")
              .orderBy("createdAt", descending: true)
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
              return Center(
                child: Text(
                    "Follow or join requests for ${widget.group.name} will appear here"),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data!.docs[index];
                  Request request = Request.fromJson(
                      json: item.data() as Map<String, dynamic>);

                  return RequestNotificationTile(
                      onAccept: () => _onAccept(
                          groupId: widget.group.id,
                          requestType: request.requestType,
                          userId: request.requester),
                      onDeny: () => _onDeny(
                          groupId: widget.group.id,
                          requestType: request.requestType,
                          userId: request.requester),
                      request: request);
                });
          }),
    );
  }
}
