import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/request.dart';
import 'package:group_app/ui/screens/home/notifications/request_notification_tile.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';

class GroupNotificationScreen extends StatefulWidget {
  const GroupNotificationScreen({super.key, required this.group});
  final Group group;

  @override
  State<GroupNotificationScreen> createState() =>
      _GroupNotificationScreenState();
}

class _GroupNotificationScreenState extends State<GroupNotificationScreen> {
  final List<Request> _requests = [];
  DocumentSnapshot? _lastDoc;

  int _count = 0;

  Future<void> _onAccept() async {}

  Future<void> _onDeny() async {}

  Future<void> _loadMore() async {
    Query query = FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.group.id)
        .collection("requests")
        .orderBy("createdAt", descending: true);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    } else {
      // first time
      _count = (await query.count().get()).count;
    }
    QuerySnapshot querySnapshot = await query.limit(10).get();

    _lastDoc = querySnapshot.docs.last;
    _requests.addAll(querySnapshot.docs.map(
        (doc) => Request.fromJson(json: doc.data() as Map<String, dynamic>)));
  }

  @override
  void initState() {
    super.initState();
    _loadMore().then((value) => setState(
          () {},
        ));
  }

  @override
  Widget build(BuildContext context) {
    const double groupIconSize = 30;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: context.pop,
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  context.push("/group", extra: widget.group);
                },
                child: BasicCircleAvatar(
                    radius: groupIconSize / 2,
                    child: widget.group.icon(groupIconSize)),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.group.name,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: _count == 0
            ? const Center(
                child: Text("Follow and join requests will appear here"),
              )
            : ListView.builder(
                itemCount: _count,
                itemBuilder: (context, index) {
                  if (index >= _requests.length) {
                    _loadMore().then((value) => setState(
                          () {},
                        ));
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }
                  return RequestNotificationTile(
                      onAccept: _onAccept,
                      onDeny: _onDeny,
                      request: _requests[index]);
                },
              ));
  }
}
