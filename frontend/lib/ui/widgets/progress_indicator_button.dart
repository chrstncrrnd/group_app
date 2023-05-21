import 'dart:async';

import 'package:flutter/material.dart';

/// Both child and text cannot be null
class ProgressIndicatorButton extends StatefulWidget {
  const ProgressIndicatorButton(
      {super.key,
      required this.onPressed,
      this.text,
      this.style,
      this.child,
      this.progressIndicatorHeight,
      this.progressIndicatorWidth})
      : assert(text != null || child != null);

  final FutureOr<void> Function() onPressed;
  final String? text;
  final Widget? child;
  final ButtonStyle? style;
  final double? progressIndicatorWidth;
  final double? progressIndicatorHeight;

  @override
  State<ProgressIndicatorButton> createState() =>
      _ProgressIndicatorButtonState();
}

class _ProgressIndicatorButtonState extends State<ProgressIndicatorButton> {
  bool loading = false;

  void onPressed() async {
    // don't execute again if its already executing
    if (loading) return;

    setState(() {
      loading = true;
    });

    await widget.onPressed.call();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: widget.style,
      child: loading
          ? SizedBox(
              width: widget.progressIndicatorWidth,
              height: widget.progressIndicatorHeight,
              child: const CircularProgressIndicator.adaptive())
          : widget.child ?? Text(widget.text!),
    );
  }
}
