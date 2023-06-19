import 'package:flutter/material.dart';

class StatWidget extends StatelessWidget {
  const StatWidget(
      {super.key, required this.name, required this.value, this.onPressed});

  final Function()? onPressed;

  final String name;
  final int value;

  void _onPressed() {
    if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _onPressed,
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade100,
                fontSize: 18),
          ),
          Text(
            name,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
