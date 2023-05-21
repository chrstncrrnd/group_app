import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          actions: [
            IconButton(
                onPressed: () => context.push("/notifications"),
                icon: const Icon(Icons.notifications_none_rounded))
          ],
          centerTitle: true,
        ),
        body: const Center(
            child: Text(
          "Feed screen",
          style: TextStyle(fontSize: 20),
        )));
  }
}
