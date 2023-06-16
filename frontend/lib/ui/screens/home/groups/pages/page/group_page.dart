import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/services/group/group_update.dart';
import 'package:group_app/ui/screens/home/groups/pages/page/edit_page_sheet.dart';
import 'package:group_app/ui/widgets/adaptive_dialog.dart';
import 'package:group_app/ui/widgets/alert.dart';
import 'package:group_app/ui/widgets/context_menu.dart';
import 'package:group_app/ui/widgets/paginated_stream/paginated_streamed_list_view.dart';
import 'package:group_app/ui/widgets/progress_indicator_button.dart';
import 'package:provider/provider.dart';

class GroupPageExtra {
  GroupPage page;
  Group group;
  GroupPageExtra({required this.page, required this.group});
}

class GroupPageScreen extends StatelessWidget {
  const GroupPageScreen({super.key, required this.extra});

  final GroupPageExtra extra;

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

  @override
  Widget build(BuildContext context) {
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
              title: Text(page.name),
              centerTitle: true,
              actions: [
                if (extra.group.admins.contains(currentUser.id))
                  _adminButtons(context, page)
              ],
            ),
            body: Column(
              children: [
                Text(
                    "${page.contributors.length} contributor${page.contributors.length == 1 ? '' : 's'}"),
                const Divider(
                  thickness: 1,
                  height: 30,
                  indent: 20,
                  endIndent: 20,
                  color: Color.fromARGB(50, 255, 255, 255),
                ),
                Expanded(
                  child: PaginatedStreamedListView(
                    query: FirebaseFirestore.instance
                        .collection("groups")
                        .doc(page.groupId)
                        .collection("pages")
                        .doc(page.id)
                        .collection("posts"),
                    pageSize: 10,
                    itemBuilder: (context, item) {
                      var post = Post.fromJson(
                          json: item.data() as Map<String, dynamic>,
                          id: item.id);

                      return Column(children: [
                        Text(post.createdAt.toIso8601String()),
                        Image.network(post.dlUrl)
                      ]);
                    },
                  ),
                )
              ],
            ),
            floatingActionButton: _newPostButton(context, page),
          );
        });
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
                onPressed: () => _deletePage(
                      context, page
                    ),
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
      return TextButton.icon(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.black)),
          onPressed: () => context.push("/take_new_post", extra: page),
          icon: const Icon(Icons.add),
          label: const Text("New post"));
    } else {
      return null;
    }
  }
}
