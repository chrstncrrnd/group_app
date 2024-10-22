
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/services/current_user_provider.dart';
import 'package:groopo/ui/screens/home/groups/widgets/group_list_tile.dart';
import 'package:groopo/ui/widgets/firestore_views/paginated/list_view.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUserProvider =
        Provider.of<CurrentUserProvider>(context, listen: true);

    if (currentUserProvider.currentUser == null) {
      return const Center(
        child: Text("Something went wrong"),
      );
    }

    var currentUser = currentUserProvider.currentUser!;

    Widget placeholder(BuildContext context) {
      return const GroupListTileLoading();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My groups",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
        ),
        actions: [
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
      body: PaginatedListView(
        loaderBuilder: placeholder,
        shrinkWrap: false,
        pullToRefresh: true,
        ifEmpty: const Center(
          child: Text(
            "Create or join a group",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        query: FirebaseFirestore.instance
            .collection("groups")
            .where("members", arrayContains: currentUser.id)
            .orderBy("lastChange", descending: true),
        itemBuilder: (context, item) {
          var group = Group.fromJson(
              json: item.data() as Map<String, dynamic>, id: item.id);
          return Column(children: [
            GroupListTile(group: group),
            const Divider(
              height: 1,
              indent: 30,
              endIndent: 30,
              color: Color.fromARGB(47, 255, 255, 255),
            )
          ]);
        },
      ),
    );
  }
}
