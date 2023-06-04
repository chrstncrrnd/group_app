import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:group_app/models/group.dart";
import "package:group_app/ui/widgets/text_input_field.dart";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _groupId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            TextInputField(
                label: "group id", onChanged: (val) => _groupId = val),
            TextButton(
                onPressed: () async {
                  var group = await Group.fromId(id: _groupId);
                  context.push("/group", extra: group);
                },
                child: const Text("Open"))
          ],
        ),
      ),
    );
  }
}
