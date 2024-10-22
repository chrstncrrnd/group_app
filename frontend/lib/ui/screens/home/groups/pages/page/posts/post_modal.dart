import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide showAdaptiveDialog;
import 'package:go_router/go_router.dart';
import 'package:groopo/models/comment.dart';
import 'package:groopo/models/current_user.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/post.dart';
import 'package:groopo/models/user.dart';
import 'package:groopo/services/current_user_provider.dart';
import 'package:groopo/services/posts.dart';
import 'package:groopo/ui/widgets/async/suspense.dart';
import 'package:groopo/ui/widgets/basic_circle_avatar.dart';
import 'package:groopo/ui/widgets/buttons/progress_indicator_button.dart';
import 'package:groopo/ui/widgets/dialogs/adaptive_dialog.dart';
import 'package:groopo/ui/widgets/dialogs/alert.dart';
import 'package:groopo/utils/max.dart';
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
      const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(1, 1));

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUserProvider>(context).currentUser!;

    return Material(
      surfaceTintColor: Colors.black,
      color: Colors.black,
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
    return Center(
        child: Hero(
            tag: post.id,
            child: InteractiveViewer(
                child: CachedNetworkImage(imageUrl: post.dlUrl))));
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
    String? caption = extra.post.caption;
    if (caption == null) {
      return Container();
    }
    bool expanded = false;
    return StatefulBuilder(builder: (context, setState) {
      return GestureDetector(
        onTap: () => setState(() => expanded = !expanded),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            caption,
            style: TextStyle(
                shadows: [defaultShadow], overflow: TextOverflow.ellipsis),
            maxLines: expanded ? 100 : 1,
          ),
        ),
      );
    });
  }

  Widget commentsSheet(BuildContext context) {
    TextEditingController controller = TextEditingController();
    bool sending = false;

    Future<void> submitComment() async {
      if (sending) {
        return;
      }
      sending = true;
      String? comment = controller.value.text.trim();

      if (comment == "") {
        return;
      }

      await addComment(
          extra.group.id, extra.post.pageId, extra.post.id, comment);

      controller.clear();
      sending = false;
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Comments",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("groups")
                .doc(extra.group.id)
                .collection("pages")
                .doc(extra.post.pageId)
                .collection("posts")
                .doc(extra.post.id)
                .collection("comments")
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return const Center(
                  child: Text("Something went wrong..."),
                );
              }
              List<Comment> comments = snapshot.data!.docs
                  .map((e) => Comment.fromJson(json: e.data(), id: e.id))
                  .toList();
              return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment = comments[index];
                    return Suspense(
                        future: User.fromId(id: comment.commenterId),
                        builder: (context, user) {
                          if (user == null) {
                            return const Text("Something went wrong...");
                          }
                          const double pfpSize = 17;

                          return ListTile(
                            title: Text(user.username),
                            subtitle: Text(
                              comment.comment,
                              style: const TextStyle(fontSize: 15),
                            ),
                            leading: BasicCircleAvatar(
                                radius: pfpSize, child: user.pfp(pfpSize * 2)),
                          );
                        });
                  });
            },
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: TextField(
                textInputAction: TextInputAction.send,
                onSubmitted: (_) async => submitComment(),
                controller: controller,
                minLines: 1,
                maxLines: 3,
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: submitComment, icon: const Icon(Icons.send)),
                    fillColor: Colors.white.withOpacity(0.1),
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    hintText: "Add comment",
                    border: const UnderlineInputBorder()),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget commentInputWrapper(BuildContext context, Widget child) {
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
            child: child),
      ),
    );
  }

  Widget commentsBar(BuildContext context) {
    void openComments() {
      showModalBottomSheet(
          backgroundColor: Colors.black,
          showDragHandle: true,
          useSafeArea: true,
          context: context,
          isDismissible: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: commentsSheet);
    }

    return commentInputWrapper(
        context,
        GestureDetector(
          onTap: openComments,
          child: Text(
            "Add comment",
            style: TextStyle(shadows: [defaultShadow]),
          ),
        ));
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
          const SizedBox(
            height: 10,
          ),
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
