import 'package:flutter/material.dart';

class PageTileWrapper extends StatelessWidget {
  const PageTileWrapper(
      {super.key, required this.child, this.title, this.onPressed});

  final Widget child;
  final Widget? title;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25)),
                  child: child),
            ),
          ),
        ),
        if (title != null) 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: title!,
          ),
        
      ],
    );
  }
}
