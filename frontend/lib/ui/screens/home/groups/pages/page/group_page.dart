import 'package:flutter/material.dart';
import 'package:group_app/models/page.dart';

class GroupPageScreen extends StatefulWidget {
  const GroupPageScreen({super.key, required this.page});

  final GroupPage page;

  @override
  State<GroupPageScreen> createState() => _GroupPageScreenState();
}

class _GroupPageScreenState extends State<GroupPageScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
