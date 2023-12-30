import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/current_user.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/page.dart';
import 'package:groopo/services/current_user_provider.dart';
import 'package:groopo/ui/screens/home/groups/pages/page_tile.dart';
import 'package:groopo/ui/screens/home/groups/widgets/group_list_tile.dart';
import 'package:groopo/ui/widgets/async/suspense.dart';
import 'package:groopo/ui/widgets/firestore_views/paginated/list_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CurrentUser? currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser;
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    return Suspense(
        // Note for future:
        // if the user is a member of a lot of groups, this might end up taking
        // a significant amount of time
        future: SharedPreferences.getInstance(),
        builder: (context, prefs) {
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
                ifEmpty: const Center(
                  child: Text(
                    "Follow a group to see their posts here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
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
                        showArrow: false,
                        showDescription: false,
                      ),
                      Provider.value(
                        value: group,
                        child: SizedBox(
                          height: 230,
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
                              DateTime lastSeen = DateTime.parse(
                                  prefs?.getString(page.lastSeenKey) ??
                                      "2012-02-27");
                              // 2012-02-27 is an arbitrary date,
                              // just something guaranteed to be in the past and
                              // a valid date string
                              bool seen = lastSeen.isAfter(page.lastChange);

                              return SizedBox.square(
                                  dimension: 190,
                                  child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          PageTile(page: page),
                                          // if the user hasn't seen the page in a while,
                                          // show an alert
                                          if (seen != true)
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  shape: BoxShape.circle),
                                            ),
                                        ],
                                      )));
                            },
                          ),
                        ),
                      )
                    ],
                  );
                },
              ));
        });
  }
}
