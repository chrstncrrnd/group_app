import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupsScreens extends StatelessWidget {
  const GroupsScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My groups",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
        ),
        actions: [
          IconButton(
              onPressed: () => context.go(
                    "/new_group",
                  ),
              icon: const Icon(
                Icons.add_rounded,
                size: 40,
              ))
        ],
      ),
    );
  }
}
