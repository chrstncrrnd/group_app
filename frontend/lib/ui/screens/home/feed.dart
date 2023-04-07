import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "group_app",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          centerTitle: true,
        ),
        body: const Center(
            child: Text(
          "Feed screen",
          style: TextStyle(fontSize: 20),
        )));
  }
}
