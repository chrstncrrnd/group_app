import 'package:flutter/material.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/ui/screens/home/groups/pages/new_page/new_page_sheet.dart';
import 'package:group_app/ui/screens/home/groups/pages/page_tile_wrapper.dart';
import 'package:provider/provider.dart';

class NewPageTile extends StatelessWidget {
  const NewPageTile({super.key});

  @override
  Widget build(BuildContext context) {

    Group group = Provider.of<Group>(context);
    return PageTileWrapper(
        onPressed: () => showModalBottomSheet(
              backgroundColor: Colors.black,
              showDragHandle: true,
              isScrollControlled: true,
              useRootNavigator: true,
              useSafeArea: true,
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => NewPageSheet(
                group: group,
              ),
            ),
        title: const Text(
          "Create a new page",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 37, 37, 37),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(
                Icons.add_rounded,
                size: 100,
              )),
        ));
  }
}
