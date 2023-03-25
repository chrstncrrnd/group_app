import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: Column(children: const [
        SizedBox(
          height: 30,
        ),
        Text(
          "Create a new account",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        )
      ]))),
    );
  }
}
