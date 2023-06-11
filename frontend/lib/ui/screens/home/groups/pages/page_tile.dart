import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/ui/screens/home/groups/pages/page/group_page.dart';
import 'package:group_app/ui/screens/home/groups/pages/page_tile_wrapper.dart';
import 'package:provider/provider.dart';

class PageTile extends StatelessWidget {
  const PageTile({super.key, required this.page});

  final GroupPage page;

  @override
  Widget build(BuildContext context) {
    return PageTileWrapper(
      onPressed: () => context.push("/group/page",
          extra: GroupPageExtra(
              page: page, group: Provider.of<Group>(context, listen: false))),
      title: Text(page.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      child: Text(page.id),
    );
  }
}
