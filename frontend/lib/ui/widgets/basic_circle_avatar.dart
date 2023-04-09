import 'package:flutter/material.dart';

class BasicCircleAvatar extends StatelessWidget {
  const BasicCircleAvatar(
      {super.key, required this.child, required this.radius});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius + 100),
          border: Border.all(color: Colors.white, width: 3)),
      child: CircleAvatar(
        backgroundColor: Colors.black,
        radius: radius,
        child: ClipOval(
          child: child,
        ),
      ),
    );
  }
}
