import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/async/suspense.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/utils/max.dart';
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
                        return _modalView(context, group, user);
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

  Widget _modalView(BuildContext context, Group group, User creator) {
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
                      Text("@${creator.username}"),
                      Text("in ${group.name}"),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
