import 'dart:async';

import 'package:flutter/material.dart';

class NextButton extends StatefulWidget {
  const NextButton({super.key, required this.onPressed, this.text = "Next"});

  final String text;
  final FutureOr<void> Function() onPressed;

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  bool loading = false;

  void onPressed() async {
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
      style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll(Colors.white),
          shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        child: Text(widget.text,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }
}
