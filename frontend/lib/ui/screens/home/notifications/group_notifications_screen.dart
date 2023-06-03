import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/request.dart';
import 'package:group_app/services/notifications.dart';
import 'package:group_app/ui/screens/home/notifications/widgets/request_notification_tile.dart';
import 'package:group_app/ui/widgets/paginated_streamed_list_view.dart';

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
              child: 
              Text(
                widget.group.name),
              ),
            ],
          ),
          centerTitle: true,
        ),
      body: PaginatedStreamedListView(
          pageSize: 1,
          query: FirebaseFirestore.instance
              .collection("groups")
              .doc(widget.group.id)
              .collection("requests")
              .orderBy("createdAt", descending: true),

          ifEmpty: Center(
            child: Text(
                "Follow or join requests for ${widget.group.name} will appear here"),
          ),
          itemBuilder: (context, item) {
            Request request =
                Request.fromJson(json: item.data() as Map<String, dynamic>);

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
          }),
    );
  }
}
