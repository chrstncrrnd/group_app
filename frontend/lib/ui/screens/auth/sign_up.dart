import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: Column(children: const [
        Text(
          "group_app",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          "Sign up",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        )
      ]))),
    );
  }
}
