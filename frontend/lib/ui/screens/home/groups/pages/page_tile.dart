import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/ui/screens/home/groups/pages/page/group_page.dart';
import 'package:group_app/ui/screens/home/groups/pages/page_tile_wrapper.dart';
import 'package:group_app/ui/widgets/suspense.dart';
import 'package:provider/provider.dart';

class PageTile extends StatelessWidget {
  const PageTile({super.key, required this.page});

  final GroupPage page;

  Future<List<Widget>> getRecents() async {
    var postsRef = FirebaseFirestore.instance
        .collection("groups")
        .doc(page.groupId)
        .collection("pages")
        .doc(page.id)
        .collection("posts");

    var posts =
        (await postsRef.limit(4).orderBy("createdAt", descending: true).get())
            .docs
            .map((e) => Post.fromJson(json: e.data(), id: e.id));

    return posts
        .map((e) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                e.dlUrl,
                fit: BoxFit.cover,
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return PageTileWrapper(
      onPressed: () => context.push("/group/page",
          extra: GroupPageExtra(
              page: page, group: Provider.of<Group>(context, listen: false))),
      title: Text(page.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      child: Suspense(
        future: getRecents(),
        builder: (context, data) {
          if (data == null) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }
          if (data.isEmpty) {
            return const Text("No posts yet...");
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return data[index];
            },
          );
        },
      ),
    );
  }
}
