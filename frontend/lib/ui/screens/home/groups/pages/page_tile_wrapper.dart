import 'package:flutter/material.dart';

class PageTileWrapper extends StatelessWidget {
  const PageTileWrapper({super.key, required this.child, this.title});

  final Widget child;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          title!,
          const SizedBox(
            height: 10,
          )
        ],
        AspectRatio(
          aspectRatio: 1 / 1,
          child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25)),
              child: child),
        ),
      ],
    );
  }
}
