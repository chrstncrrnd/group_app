import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/group_actions.dart';
import 'package:group_app/ui/screens/home/groups/widgets/group_list_tile.dart';
import 'package:provider/provider.dart';

class ArchivedGroupsScreen extends StatelessWidget {
  const ArchivedGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<CurrentUser>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text("Archived groups"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .where("members", arrayContains: currentUser.id)
            .where(FieldPath.documentId,
                whereIn: [...currentUser.archivedGroups, "a"]).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              children:
                  List.generate(4, (index) => const GroupListTileLoading()),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong..."),
            );
          }

          var groups = snapshot.data!.docs
              .map((e) => Group.fromJson(json: e.data(), id: e.id))
              .toList();

          if (groups.isEmpty) {
            return const Center(
              child: Text("Create or join a group"),
            );
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index];
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
          );
        },
      ),
    );
  }
}
