import 'package:flutter/material.dart';
import 'package:group_app/ui/screens/home/groups/pages/new_page/new_page_tile.dart';

class PagesGrid extends StatelessWidget {
  const PagesGrid({super.key});


  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1 / 1.2,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        return const NewPageTile();
      },
    );
  }
}
