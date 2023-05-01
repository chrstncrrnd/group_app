import 'package:flutter/material.dart';

class InteractionButton extends StatelessWidget {
  const InteractionButton(
      {super.key,
      this.onTap,
      required this.title,
      this.before,
      this.after,
      this.textStyle});

  final void Function()? onTap;
  final Widget? before;
  final Widget? after;
  final String title;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(17)),
        child: Center(
          child: Text(
            title,
            style: textStyle ??
                const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black),
          ),
        ));
  }
}
