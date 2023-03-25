import 'dart:async';

import 'package:flutter/material.dart';

/// Both child and text cannot be null
class ProgressIndicatorButton extends StatefulWidget {
  const ProgressIndicatorButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.style,
      this.child})
      : assert(text != null || child != null);

  final FutureOr<void> Function() onPressed;
  final String? text;
  final Widget? child;
  final ButtonStyle? style;

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
    return ElevatedButton(
      onPressed: onPressed,
      style: widget.style,
      child: widget.child ?? Text(widget.text!),
    );
  }
}
