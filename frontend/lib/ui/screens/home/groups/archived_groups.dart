import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/services/group/group_actions.dart';
import 'package:group_app/ui/screens/home/groups/widgets/group_list_tile.dart';
import 'package:group_app/ui/widgets/firestore_views/paginated_pull_to_refresh/list_view.dart';
import 'package:provider/provider.dart';

class ArchivedGroupsScreen extends StatelessWidget {
  const ArchivedGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUserProv =
        Provider.of<CurrentUserProvider>(context, listen: true);
    var currentUser = currentUserProv.currentUser!;
    var privateData = currentUserProv.privateData!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archived groups"),
      ),
      body: PullToRefreshPaginatedListView(
        query: FirebaseFirestore.instance
            .collection("groups")
            .where("members", arrayContains: currentUser.id)
            .where(FieldPath.documentId, whereIn: [
          "this is a fake id because where in cannot take an empty array",
          ...privateData.archivedGroups
        ]),
        ifEmpty: const Center(
          child: Text("Swipe left on a group to archive it"),
        ),
        itemBuilder: (context, item) {
          var group = Group.fromJson(
              json: item.data() as Map<String, dynamic>, id: item.id);
          return Dismissible(
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.centerRight,
                child: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(
                      Icons.unarchive,
                      color: Colors.black,
                    )),
              ),
              confirmDismiss: (direction) async {
                try {
                  await unArchiveGroup(group.id);
                  return true;
                } catch (error) {
                  log(error.toString());
                  return false;
                }
              },
              key: UniqueKey(),
              child: Column(children: [
                GroupListTile(group: group),
                const Divider(
                  height: 1,
                  indent: 30,
                  endIndent: 30,
                  color: Color.fromARGB(47, 255, 255, 255),
                )
              ]));
        },
      ),
    );
  }
}
