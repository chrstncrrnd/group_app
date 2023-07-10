import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/ui/screens/home/groups/pages/page/posts/post_tile.dart';
import 'package:group_app/ui/widgets/firestore_views/streamed_grid_view.dart';

class GridPostView extends StatelessWidget {
  const GridPostView({super.key, required this.page});

  final GroupPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: StreamedGridView(
        pageSize: 5,
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1 / 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemBuilder: (context, item) {
          return PostTile(
            post: Post.fromJson(
                json: item.data() as Map<String, dynamic>, id: item.id),
          );
        },
      ),
    );
  }
}
