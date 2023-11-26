import 'dart:ui';

import 'package:flutter/material.dart' hide showAdaptiveDialog;
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/services/posts.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/buttons/progress_indicator_button.dart';
import 'package:group_app/ui/widgets/dialogs/adaptive_dialog.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';
import 'package:group_app/utils/max.dart';
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

  final defaultShadow =
      const Shadow(color: Colors.black, blurRadius: 7, offset: Offset(1, 1));

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
        child: StreamBuilder(
            stream: Post.asStream(
                groupId: extra.group.id,
                pageId: extra.post.pageId,
                id: extra.post.id),
            initialData: extra.post,
            builder: (context, state) {
              if (state.hasError || !state.hasData || state.data == null) {
                return const Center(
                  child: Text("Something went wrong"),
                );
              }
              Post post = state.data!;
              return SafeArea(
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    postPicture(context, post),
                    topRow(context, currentUser, post),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: bottomRow(context, currentUser, post))
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget topRow(BuildContext context, CurrentUser currentUser, Post post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close_rounded,
              shadows: [defaultShadow],
            )),
        if (post.creatorId == currentUser.id ||
            extra.group.admins.contains(currentUser.id))
          deletePostButton(context, post),
      ],
    );
  }

  void handleDeletePost(BuildContext context, Post post) {
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
              return await deletePost(post.groupId, post.pageId, post.id);
            },
            afterPressed: (value) {
              if (value == null) {
                context.pop();
                context.pop();
              } else {
                context.pop();
                showAlert(context,
                    title: "Something went wrong", content: value);
              }
            },
            child: const Text("Delete")),
      ],
    );
  }

  Widget deletePostButton(BuildContext context, Post post) {
    return IconButton(
      onPressed: () => handleDeletePost(context, post),
      icon: Icon(
        Icons.delete_outline,
        shadows: [defaultShadow],
      ),
    );
  }

  Widget postPicture(BuildContext context, Post post) {
    return Center(child: Hero(tag: post.id, child: Image.network(post.dlUrl)));
  }

  Widget likeButton(BuildContext context, CurrentUser currentUser, Post post) {
    bool liked = post.likes.contains(currentUser.id);
    int likeCount = post.likes.length;

    void onInteractWithLike() async {
      if (!liked) {
        await likePost(extra.group.id, post.pageId, post.id);
      } else {
        await unlikePost(extra.group.id, post.pageId, post.id);
      }
    }

    return Column(
      children: [
        IconButton(
          onPressed: () => onInteractWithLike(),
          icon: Icon(
            Icons.favorite,
            shadows: [defaultShadow],
            size: 40,
            // TODO: animate this color change
            color: liked ? const Color.fromARGB(255, 255, 5, 88) : Colors.white,
          ),
        ),
        Text(
          "$likeCount",
          style: TextStyle(
              shadows: [defaultShadow],
              fontSize: 15,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget caption(BuildContext context) {
    const text =
        "et ultrices neque ornare aenean euismod elementum nisi quis eleifend quam adipiscing vitae proin sagittis nisl rhoncus mattis rhoncus urna neque viverra justo nec ultrices dui sapien eget mi proin sed libero enim sed faucibus turpis in eu mi bibendum";

    bool expanded = false;

    return StatefulBuilder(builder: (context, setState) {
      return GestureDetector(
        onTap: () => setState(() => expanded = !expanded),
        child: Align(
          child: Text(
            text,
            style: TextStyle(
                shadows: [defaultShadow], overflow: TextOverflow.ellipsis),
            maxLines: expanded ? 100 : 1,
          ),
        ),
      );
    });
  }

  Widget commentsBar(BuildContext context) {
    var borderRadius = BorderRadius.circular(100);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: Max.width(context),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            border: Border.all(color: Colors.white),
            borderRadius: borderRadius,
          ),
          child: Text(
            "Add comment",
            style: TextStyle(shadows: [defaultShadow]),
          ),
        ),
      ),
    );
  }

  Widget bottomRow(BuildContext context, CurrentUser currentUser, Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              creatorAndLocation(context),
              likeButton(context, currentUser, post)
            ],
          ),
          caption(context),
          commentsBar(context)
        ],
      ),
    );
  }

  Widget profilePictures(double iconSize) {
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

  Widget creatorAndLocation(BuildContext context) {
    return Row(
      children: [
        profilePictures(30),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () {
                  context.replace("/user", extra: extra.creator);
                },
                child: Text(
                  "@${extra.creator.username}",
                  style: TextStyle(shadows: [defaultShadow]),
                )),
            GestureDetector(
                onTap: () {
                  context.replace("/group", extra: extra.group);
                },
                child: Text("in ${extra.group.name}",
                    style: TextStyle(shadows: [defaultShadow]))),
          ],
        ),
      ],
    );
  }
}
