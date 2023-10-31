import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/ui/screens/home/groups/pages/page_tile.dart';
import 'package:group_app/ui/screens/home/groups/widgets/group_list_tile.dart';
import 'package:group_app/ui/widgets/firestore_views/paginated/list_view.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CurrentUser? currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser;

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Groopo",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          actions: [
            IconButton(
                onPressed: () => context.push("/notifications"),
                icon: const Icon(Icons.notifications_none_rounded))
          ],
          centerTitle: true,
        ),
        body: PaginatedListView(
          shrinkWrap: false,
          pullToRefresh: true,
          query: FirebaseFirestore.instance
              .collection("groups")
              .where("followers", arrayContains: currentUser.id)
              .orderBy("lastChange", descending: true),
          itemBuilder: (context, item) {
            Group group = Group.fromJson(
                json: item.data() as Map<String, dynamic>, id: item.id);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupListTile(
                  group: group,
                ),

                Provider.value(
                  value: group,
                  child: SizedBox(
                    height: 232,
                    child: PaginatedListView(
                      ifEmpty: const Center(
                        child: Text(
                          "No pages here yet...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      scrollDirection: Axis.horizontal,
                      query: FirebaseFirestore.instance
                          .collection("groups")
                          .doc(group.id)
                          .collection("pages")
                          .orderBy("lastChange", descending: true),
                      itemBuilder: (context, item) {
                        GroupPage page = GroupPage.fromJson(
                            json: item.data() as Map<String, dynamic>,
                            id: item.id);
                        return SizedBox.square(
                            dimension: 200,
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: PageTile(page: page)));
                      },
                    ),
                  ),
                )
              ],
            );
          },
        ));
  }
}
