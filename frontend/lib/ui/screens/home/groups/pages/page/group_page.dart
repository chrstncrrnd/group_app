import 'package:flutter/material.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:provider/provider.dart';

class GroupPageExtra {
  GroupPage page;
  Group group;
  GroupPageExtra({required this.page, required this.group});
}

class GroupPageScreen extends StatefulWidget {
  const GroupPageScreen({super.key, required this.extra});

  final GroupPageExtra extra;

  @override
  State<GroupPageScreen> createState() => _GroupPageScreenState();
}

class _GroupPageScreenState extends State<GroupPageScreen> {
  late final GroupPage _page;
  late final Group _group;

  @override
  void initState() {
    // this is just so that you don't have to type
    // widget.extra.page just to access the page
    _page = widget.extra.page;
    _group = widget.extra.group;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_page.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _contributors(),
          const Divider(
            thickness: 1,
            height: 30,
            indent: 20,
            endIndent: 20,
            color: Color.fromARGB(50, 255, 255, 255),
          )
        ],
      ),
      floatingActionButton: _newPostButton(),
    );
  }

  Widget? _newPostButton() {
    final CurrentUser currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser!;
    if (_group.members.contains(currentUser.id)) {
      return TextButton.icon(
          onPressed: () => print("new post"),
          icon: const Icon(Icons.add),
          label: const Text("New post"));
    } else {
      return null;
    }
  }

  Widget _contributors() {
    return const Column(
      children: [
        Text("Contributors"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("tbd")],
        )
      ],
    );
  }
}
