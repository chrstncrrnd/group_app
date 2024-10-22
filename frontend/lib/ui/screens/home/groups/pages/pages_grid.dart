import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groopo/models/current_user.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/page.dart';
import 'package:groopo/services/current_user_provider.dart';
import 'package:groopo/ui/screens/home/groups/pages/page_tile.dart';
import 'package:groopo/ui/widgets/firestore_views/paginated/grid_view.dart';
import 'package:provider/provider.dart';

import 'new_page/new_page_tile.dart';

class PagesGrid extends StatelessWidget {
  const PagesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final Group group = Provider.of<Group>(context);
    final CurrentUser currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser!;
    return PaginatedGridView(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1 / 1.23,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        query: FirebaseFirestore.instance
            .collection("groups")
            .doc(group.id)
            .collection("pages")
            .orderBy("lastChange", descending: true),
        before: currentUser.adminOf.contains(group.id) ||
                currentUser.memberOf.contains(group.id)
            ? const [NewPageTile()]
            : null,
        itemBuilder: (context, item) => PageTile(
            page: GroupPage.fromJson(
                json: item.data() as Map<String, dynamic>,
                id: item.id,
                cachedGroupData: group)));
  }
}
