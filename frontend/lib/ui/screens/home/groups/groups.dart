import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/services/group_actions.dart';
import 'package:group_app/ui/screens/home/groups/widgets/group_list_tile.dart';
import 'package:group_app/ui/widgets/paginated_streamed_list_view.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUserProvider =
        Provider.of<CurrentUserProvider>(context, listen: true);
    var currentUser = currentUserProvider.currentUser!;
    var privateData = currentUserProvider.privateData!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My groups",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
        ),
        actions: [
          IconButton(
              onPressed: () => context.push("/archived_groups"),
              icon: const Icon(Icons.archive_outlined)),
          IconButton(
              onPressed: () => context.push(
                    "/new_group",
                  ),
              icon: const Icon(
                Icons.add_rounded,
                size: 40,
              ))
        ],
      ),
      body: PaginatedStreamedListView(
        query: FirebaseFirestore.instance
            .collection("groups")
            .where("members", arrayContains: currentUser.id)
            .where(FieldPath.documentId,
                whereNotIn: [...privateData.archivedGroups, "a"]),
        pageSize: 1,
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
                      Icons.archive,
                      color: Colors.black,
                    )),
              ),
              confirmDismiss: (direction) async {
                try {
                  await archiveGroup(group.id);
                  privateData.archivedGroups.add(group.id);
                  return true;
                } catch (e) {
                  log(e.toString());
                  return false;
                }
              },
              key: Key(group.toString()),
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
