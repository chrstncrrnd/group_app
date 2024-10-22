import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/page.dart';
import 'package:groopo/models/post.dart';
import 'package:groopo/ui/screens/home/groups/pages/page/group_page.dart';
import 'package:groopo/ui/screens/home/groups/pages/page_tile_wrapper.dart';
import 'package:groopo/ui/widgets/async/shimmer_loading_indicator.dart';
import 'package:groopo/ui/widgets/async/suspense.dart';
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
        .map((e) => Image.network(
              e.dlUrl,
              fit: BoxFit.cover,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget placeholder(BuildContext context) {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6),
        itemCount: 4,
        itemBuilder: (context, index) {
          return ShimmerLoadingIndicator(
            child: Container(
              color: Colors.grey.shade900,
            ),
          );
        },
      );
    }

    return PageTileWrapper(
      onPressed: () => context.push("/group/page",
          extra: GroupPageExtra(
              page: page, group: Provider.of<Group>(context, listen: false))),
      title: Text(
        page.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      child: Center(
        child: Suspense(
          future: getRecents(),
          placeholder: placeholder(context),
          builder: (context, data) {
            if (data == null) {
              return const Text("Something went wrong");
            }
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6),
              itemCount: 4,
              itemBuilder: (context, index) {
                var child = index < data.length
                    ? data[index]
                    : Container(
                        color: Colors.grey.shade900,
                      );

                return ClipRRect(
                    borderRadius: BorderRadius.circular(10), child: child);
              },
            );
          },
        ),
      ),
    );
  }
}
