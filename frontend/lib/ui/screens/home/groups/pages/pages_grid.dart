import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/ui/screens/home/groups/pages/new_page/new_page_tile.dart';
import 'package:group_app/ui/screens/home/groups/pages/page_tile.dart';
import 'package:group_app/ui/widgets/paginated_stream/paginated_streamed_grid_view.dart';
import 'package:provider/provider.dart';

class PagesGrid extends StatelessWidget {
  const PagesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final Group group = Provider.of<Group>(context);
    return PaginatedStreamedGridView(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1 / 1.2,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        pageSize: 10,
        query: FirebaseFirestore.instance
            .collection("groups")
            .doc(group.id)
            .collection("pages")
            .orderBy("lastChange", descending: true),
        before: const [NewPageTile()],
        itemBuilder: (context, item) => PageTile(
            page: GroupPage.fromJson(
                json: item.data() as Map<String, dynamic>, id: item.id)));

  }
}