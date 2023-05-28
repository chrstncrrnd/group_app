import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/group_actions.dart';
import 'package:group_app/ui/screens/home/groups/widgets/group_list_tile.dart';
import 'package:group_app/ui/widgets/paginated_streamed_list_view.dart';
import 'package:provider/provider.dart';

class ArchivedGroupsScreen extends StatelessWidget {
  const ArchivedGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<CurrentUser>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text("Archived groups"),
      ),
      body: PaginatedStreamedListView(
        query: FirebaseFirestore.instance
            .collection("groups")
            .where("members", arrayContains: currentUser.id)
            .where(FieldPath.documentId,
                whereIn: [...currentUser.archivedGroups, "a"]),
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
                          Icons.unarchive,
                          color: Colors.black,
                        )),
                  ),
                  confirmDismiss: (direction) async {
                    try {
                      await unArchiveGroup(group.id);
                      currentUser.archivedGroups.remove(group.id);
                      return true;
                    } catch (error) {
                      log(error.toString());
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
