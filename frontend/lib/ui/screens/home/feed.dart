import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/ui/screens/home/groups/pages/page/posts/post_tile.dart';
import 'package:group_app/ui/widgets/async/suspense.dart';
import 'package:group_app/ui/widgets/paginated_stream/paginated_streamed_grid_view.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CurrentUser currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser!;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "group_app",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          actions: [
            IconButton(
                onPressed: () => context.push("/notifications"),
                icon: const Icon(Icons.notifications_none_rounded))
          ],
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: PaginatedStreamedGridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1 / 1.4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            query: FirebaseFirestore.instance
                .collectionGroup("posts")
                .where("groupId", whereIn: [
              "",
              ...currentUser.following
            ])
                .orderBy("createdAt", descending: true),
            itemBuilder: (context, item) {
              var post = Post.fromJson(
                  json: item.data() as Map<String, dynamic>, id: item.id);
              return Suspense<Group>(
                  future: Group.fromId(id: post.groupId),
                  builder: (context, group) {
                    return Provider.value(
                        value: group, child: PostTile(post: post));
                  });
            },
          ),
        ));
  }
}
