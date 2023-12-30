import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/post.dart';
import 'package:groopo/models/user.dart';
import 'package:groopo/ui/widgets/async/shimmer_loading_indicator.dart';
import 'package:groopo/ui/widgets/async/suspense.dart';
import 'package:groopo/utils/max.dart';

import 'post_modal.dart';

class PostTile extends StatelessWidget {
  const PostTile(
      {super.key,
      required this.post,
      this.showGroupName = true,
      this.showUsername = true,
      required this.group})
      : assert(showGroupName || showUsername);

  final Post post;
  final bool showUsername;
  final bool showGroupName;
  final Group group;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(BuildContext context) {
      return Stack(
        alignment: Alignment.bottomLeft,
        children: [
          SizedBox(
              width: Max.width(context),
              height: Max.height(context),
              child: ShimmerLoadingIndicator(child: Container())),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showUsername)
                  const ShimmerLoadingIndicator(
                    child: Text(
                      "username",
                    ),
                  ),
                if (showGroupName)
                  const ShimmerLoadingIndicator(child: Text("group.name"))
              ],
            ),
          ),
        ],
      );
    }

    return Suspense<User>(
        future: User.fromId(id: post.creatorId),
        placeholder: placeholder(context),
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
                    context.push("/post_modal",
                        extra: PostModalScreenExtra(
                            post: post, group: group, creator: user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Hero(
                      tag: post.id,
                      child: Image.network(
                        post.dlUrl,
                        fit: BoxFit.cover,
                      ),
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
}
