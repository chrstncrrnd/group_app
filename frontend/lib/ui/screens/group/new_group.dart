import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go("/groups"),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
    );
  }
}
