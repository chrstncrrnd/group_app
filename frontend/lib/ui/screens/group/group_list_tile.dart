import 'package:flutter/material.dart';
import 'package:group_app/models/group.dart';

class GroupListTile extends StatelessWidget {
  const GroupListTile({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          group.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        if (group.description != null)
          Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text(group.description!))
      ]),
    );
  }
}
