import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/services/posts.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/buttons/progress_indicator_button.dart';
import 'package:group_app/ui/widgets/dialogs/adaptive_dialog.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';
import 'package:provider/provider.dart';

class PostModalScreenExtra {
  const PostModalScreenExtra({
    required this.post,
    required this.group,
    required this.creator,
  });

  final Post post;
  final Group group;
  final User creator;
}

class PostModalScreen extends StatelessWidget {
  const PostModalScreen({
    super.key,
    required this.extra,
  });

  final PostModalScreenExtra extra;

  Widget _icons(double iconSize) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: iconSize / 2,
              child: BasicCircleAvatar(
                  radius: iconSize / 2, child: extra.group.icon(iconSize)),
            ),
            BasicCircleAvatar(
                radius: iconSize / 2, child: extra.creator.pfp(iconSize)),
          ],
        ),
        SizedBox(width: iconSize / 2 + 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUserProvider>(context).currentUser!;

    return Material(
      surfaceTintColor: Colors.black,
      color: Colors.black,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy.abs() > 3) {
            context.pop();
          }
        },
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              Center(
                  child: Hero(
                      tag: extra.post.id,
                      child: Image.network(extra.post.dlUrl))),
              Row(
                children: [
                  IconButton(
                      onPressed: context.pop, icon: const Icon(Icons.close)),
                  _icons(30),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {
                            context.pop();
                            context.push("/user", extra: extra.creator);
                          },
                          child: Text("@${extra.creator.username}")),
                      GestureDetector(
                          onTap: () {
                            context.pop();
                            context.push("/group", extra: extra.group);
                          },
                          child: Text("in ${extra.group.name}")),
                    ],
                  ),
                ],
              ),
              if (extra.post.creatorId == currentUser.id ||
                  extra.group.admins.contains(currentUser.id))
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      showAdaptiveDialog(
                        context,
                        title: const Text("Delete post?"),
                        content: const Text(
                            "This action cannot be undone. Are you sure you want to delete this post?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text("Cancel")),
                          ProgressIndicatorButton(
                              onPressed: () async {
                                return await deletePost(extra.post.groupId,
                                    extra.post.pageId, extra.post.id);
                              },
                              afterPressed: (value) {
                                if (value == null) {
                                  context.pop();
                                  context.pop();
                                } else {
                                  context.pop();
                                  showAlert(context,
                                      title: "Something went wrong",
                                      content: value);
                                }
                              },
                              child: const Text("Delete")),
                        ],
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
