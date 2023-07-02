import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/services/posts.dart';
import 'package:group_app/ui/widgets/async/suspense.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/buttons/progress_indicator_button.dart';
import 'package:group_app/ui/widgets/dialogs/adaptive_dialog.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';
import 'package:group_app/utils/max.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

class PostTile extends StatelessWidget {
  const PostTile(
      {super.key,
      required this.post,
      this.showGroupName = true,
      this.showUsername = true})
      : assert(showGroupName || showUsername);

  final Post post;
  final bool showUsername;
  final bool showGroupName;

  @override
  Widget build(BuildContext context) {
    var group = Provider.of<Group>(context);
    return Suspense<User>(
        future: User.fromId(id: post.creatorId),
        builder: (context, user) {
          if (user == null) {
            return const Center(child: Text("Something went wrong"));
          }

          CurrentUser currentUser =
              Provider.of<CurrentUserProvider>(context).currentUser!;

          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              SizedBox(
                width: Max.width(context),
                height: Max.height(context),
                child: GestureDetector(
                  onTap: () {
                    showGeneralDialog(
                      useRootNavigator: true,
                      context: context,
                      pageBuilder: (context, _, __) {
                        return _modalView(context, group, user, currentUser);
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      post.dlUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: FittedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showUsername)
                        Text("@${user.username}",
                            style: const TextStyle(shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                              )
                            ])),
                      if (showGroupName)
                        Text("in ${group.name}",
                            style: const TextStyle(shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                              )
                            ]))
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget _modalView(BuildContext context, Group group, User creator,
      CurrentUser currentUser) {
    Widget icons(double iconSize) {
      return Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: iconSize / 2,
                child: BasicCircleAvatar(
                    radius: iconSize / 2, child: group.icon(iconSize)),
              ),
              BasicCircleAvatar(
                  radius: iconSize / 2, child: creator.pfp(iconSize)),
            ],
          ),
          SizedBox(width: iconSize / 2 + 10),
        ],
      );
    }

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
              Center(child: Image.network(post.dlUrl)),
              Row(
                children: [
                  IconButton(
                      onPressed: context.pop, icon: const Icon(Icons.close)),
                  icons(30),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {
                            context.pop();
                            context.push("/user", extra: creator);
                          },
                          child: Text("@${creator.username}")),
                      GestureDetector(
                          onTap: () {
                            context.pop();
                            context.push("/group", extra: group);
                          },
                          child: Text("in ${group.name}")),
                    ],
                  ),
                ],
              ),
              if (post.creatorId == currentUser.id ||
                  group.admins.contains(currentUser.id))
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
                                return await deletePost(
                                    post.groupId, post.pageId, post.id);
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
