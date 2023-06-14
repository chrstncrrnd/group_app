import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/services/group/group_update.dart';
import 'package:group_app/ui/screens/home/groups/pages/page/edit_page_sheet.dart';
import 'package:group_app/ui/widgets/adaptive_dialog.dart';
import 'package:group_app/ui/widgets/alert.dart';
import 'package:group_app/ui/widgets/context_menu.dart';
import 'package:group_app/ui/widgets/progress_indicator_button.dart';
import 'package:provider/provider.dart';

class GroupPageExtra {
  GroupPage page;
  Group group;
  GroupPageExtra({required this.page, required this.group});
}

class GroupPageScreen extends StatefulWidget {
  const GroupPageScreen({super.key, required this.extra});

  final GroupPageExtra extra;

  @override
  State<GroupPageScreen> createState() => _GroupPageScreenState();
}

class _GroupPageScreenState extends State<GroupPageScreen> {
  late final GroupPage _page;
  late final Group _group;

  @override
  void initState() {
    // this is just so that you don't have to type
    // widget.extra.page just to access the page
    _page = widget.extra.page;
    _group = widget.extra.group;
    super.initState();
  }

  Future<void> _editPage() async {
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
        group: _group,
        page: _page,
      ),
    );

  }

  Future<void> _deletePage(BuildContext context) async {
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
                  await deletePage(groupId: _page.groupId, pageId: _page.id);
                    } catch (e) {
                      await showAlert(context,
                          title:
                              "Something went wrong while deleting this page");
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_page.name),
        centerTitle: true,
        actions: [
          if (_group.admins.contains(currentUser.id)) _adminButtons(context)
        ],
      ),
      body: Column(
        children: [
          _contributors(),
          const Divider(
            thickness: 1,
            height: 30,
            indent: 20,
            endIndent: 20,
            color: Color.fromARGB(50, 255, 255, 255),
          )
        ],
      ),
      floatingActionButton: _newPostButton(),
    );
  }

  Widget _adminButtons(BuildContext context) {
    return IconButton(
        onPressed: () => showContextMenu(
            context: context,
            items: [
              (
                child: const Text("Edit page"),
                onPressed: _editPage,
                icon: const Icon(Icons.edit_outlined)
              ),
              (
                child: const Text("Delete page"),
                onPressed: () => _deletePage(
                      context,
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


  Widget? _newPostButton() {
    final CurrentUser currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser!;
    if (_group.members.contains(currentUser.id)) {
      return TextButton.icon(
          onPressed: () => print("new post"),
          icon: const Icon(Icons.add),
          label: const Text("New post"));
    } else {
      return null;
    }
  }

  Widget _contributors() {
    return const Column(
      children: [
        Text("Contributors"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("tbd")],
        )
      ],
    );
  }
}
