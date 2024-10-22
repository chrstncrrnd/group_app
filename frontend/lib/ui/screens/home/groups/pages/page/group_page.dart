import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide showAdaptiveDialog;
import 'package:go_router/go_router.dart';
import 'package:groopo/models/current_user.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/page.dart';
import 'package:groopo/models/post.dart';
import 'package:groopo/models/user.dart';
import 'package:groopo/services/current_user_provider.dart';
import 'package:groopo/services/group/group_update.dart';
import 'package:groopo/ui/screens/home/groups/affiliated_users.dart';
import 'package:groopo/ui/screens/home/groups/pages/page/edit_page_sheet.dart';
import 'package:groopo/ui/widgets/async/shimmer_loading_indicator.dart';
import 'package:groopo/ui/widgets/async/suspense.dart';
import 'package:groopo/ui/widgets/basic_circle_avatar.dart';
import 'package:groopo/ui/widgets/buttons/progress_indicator_button.dart';
import 'package:groopo/ui/widgets/dialogs/adaptive_dialog.dart';
import 'package:groopo/ui/widgets/dialogs/alert.dart';
import 'package:groopo/ui/widgets/dialogs/context_menu.dart';
import 'package:groopo/ui/widgets/firestore_views/paginated/grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'posts/post_tile.dart';

class GroupPageExtra {
  GroupPage page;
  Group group;
  GroupPageExtra({required this.page, required this.group});
}

class GroupPageScreen extends StatelessWidget {
  const GroupPageScreen({super.key, required this.extra});

  final GroupPageExtra extra;

  void setSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(extra.page.lastSeenKey, DateTime.now().toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    setSeen();
    final currentUser = Provider.of<CurrentUserProvider>(context).currentUser!;
    return StreamBuilder<GroupPage>(
        initialData: extra.page,
        stream: FirebaseFirestore.instance
            .collection("groups")
            .doc(extra.page.groupId)
            .collection("pages")
            .doc(extra.page.id)
            .snapshots()
            .map((event) => GroupPage.fromJson(
                json: event.data() as Map<String, dynamic>, id: event.id)),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }
          final page = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              actions: [
                if (extra.group.admins.contains(currentUser.id))
                  _adminButtons(context, page)
              ],
            ),
            body: Column(
              children: [
                Divider(
                  color: Colors.white.withOpacity(0.2),
                  indent: 10,
                  endIndent: 10,
                  height: 2,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BasicCircleAvatar(radius: 20, child: extra.group.icon(40)),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      page.name,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                contributors(context),
                const SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: PaginatedGridView(
                      pullToRefresh: true,
                      shrinkwrap: false,
                      ifEmpty: const Center(
                        child: Text("No posts yet"),
                      ),
                      query: FirebaseFirestore.instance
                          .collection("groups")
                          .doc(page.groupId)
                          .collection("pages")
                          .doc(page.id)
                          .collection("posts")
                          .orderBy("createdAt", descending: true),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1 / 1.4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10),
                      itemBuilder: (context, item) {
                        return PostTile(
                          group: extra.group,
                          post: Post.fromJson(
                              json: item.data() as Map<String, dynamic>,
                              id: item.id),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
            floatingActionButton: _newPostButton(context, page),
          );
        });
  }

  Widget contributors(BuildContext context) {
  
    const TextStyle textStyle = TextStyle(color: Colors.grey);
    Widget placeholder(BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "By",
            style: textStyle,
          ),
          const SizedBox(
            width: 10,
          ),
          ...List.generate(
              3,
              (index) => BasicCircleAvatar(
                    radius: 10,
                    child: ShimmerLoadingIndicator(
                      child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          )),
                    ),
                  )),
        ],
      );
    }



    List<String> contributorIds = extra.page.contributors;
    void navigateToContributors() {
      context.push("/group/page/contributors",
          extra: AffiliatedUsersScreenExtra(
            users: contributorIds,
            title: "Contributors",
            isAdmin: false,
          ));
    }

    Future<List<User>> contributorsFuture = Future.wait(contributorIds
        .sublist(0, min(contributorIds.length, 4))
        .map((id) => User.fromId(id: id)));


    return Suspense(
        future: contributorsFuture,
        placeholder: placeholder(context),
        builder: (context, contributors) {
          if (contributors == null) {
            return const Text(
              "Something went wrong...",
              style: textStyle,
            );
          }
          return GestureDetector(
            onTap: navigateToContributors,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "By",
                  style: textStyle,
                ),
                const SizedBox(
                  width: 10,
                ),
                ...contributors.map((u) => BasicCircleAvatar(
                      radius: 10,
                      child: u.pfp(20),
                    )),
                if (contributorIds.length > 3) ...[
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "+ ${contributorIds.length - 3}",
                    style: textStyle,
                  )
                ]
              ],
            ),
          );
        });
  }

  Future<void> _editPage(BuildContext context, GroupPage page) async {
    await showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EditPageSheet(
        group: extra.group,
        page: page,
      ),
    );
  }

  Future<void> _deletePage(BuildContext context, GroupPage page) async {
    await showAdaptiveDialog(context,
        title: const Text("Are you sure you want to delete this page?"),
        content: const Text(
            "You won't be able to recover any posts made in this page"),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text("Cancel")),
          ProgressIndicatorButton(
              progressIndicatorHeight: 15,
              progressIndicatorWidth: 15,
              onPressed: () async {
                try {
                  await deletePage(groupId: page.groupId, pageId: page.id);
                } catch (e) {
                  await showAlert(context,
                      title: "Something went wrong while deleting this page");
                  log("Error while deleting page", error: e);
                }
              },
              afterPressed: (_) {
                context.pop();
                context.pop();
              },
              child: const Text("Delete"))
        ]);
  }

  Widget _adminButtons(BuildContext context, GroupPage page) {
    return IconButton(
        onPressed: () => showContextMenu(
            context: context,
            items: [
              (
                child: const Text("Edit page"),
                onPressed: () => _editPage(context, page),
                icon: const Icon(Icons.edit_outlined)
              ),
              (
                child: const Text("Delete page"),
                onPressed: () => _deletePage(context, page),
                icon: const Icon(Icons.delete_outline)
              )
            ],
            position: RelativeRect.fromDirectional(
                top: 0,
                end: 0,
                textDirection: TextDirection.ltr,
                start: 1,
                bottom: 1)),
        icon: const Icon(Icons.more_horiz));
  }

  Widget? _newPostButton(BuildContext context, GroupPage page) {
    final CurrentUser currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser!;
    if (extra.group.members.contains(currentUser.id)) {
      return IconButton(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.white)),
          onPressed: () => context.push("/take_new_post", extra: page),
          icon: const Icon(
            Icons.add,
            color: Colors.black,
            size: 40,
          ));
    }
    return null;
  }
}
