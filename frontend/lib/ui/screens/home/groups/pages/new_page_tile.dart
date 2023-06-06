import 'package:flutter/material.dart';
import 'package:group_app/ui/screens/home/groups/pages/page_tile_wrapper.dart';

class NewPageTile extends StatelessWidget {
  const NewPageTile({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTileWrapper(
        title: const Text(
          "Create a new page",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 37, 37, 37),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(
              Icons.add_rounded,
              size: 100,
            )));
  }
}
