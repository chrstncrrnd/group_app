import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, this.name, required this.username});

  final String? name;
  final String username;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a new account"),
      ),
      body: const Text(
        "hi",
        style: TextStyle(fontSize: 40),
      ),
    );
  }
}
