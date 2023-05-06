import 'package:flutter/material.dart';

class InteractionButton extends StatelessWidget {
  const InteractionButton(
      {super.key,
      this.onTap,
      required this.title,
      this.before,
      this.after,
      this.active = true});

  final void Function()? onTap;
  final Widget? before;
  final Widget? after;
  final String title;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: active ? Colors.white : Colors.black,
              borderRadius: BorderRadius.circular(17)),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (before != null) before!,
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: active ? Colors.black : Colors.white),
                ),
                if (after != null) after!
              ],
            ),
          )),
    );
  }
}
