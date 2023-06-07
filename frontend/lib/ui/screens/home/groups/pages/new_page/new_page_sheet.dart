import 'package:flutter/material.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';

class NewPageSheet extends StatefulWidget {
  const NewPageSheet({super.key, required this.group});

  final Group group;

  @override
  State<NewPageSheet> createState() => _NewPageSheetState();
}

class _NewPageSheetState extends State<NewPageSheet> {
  String pageName = "";
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [Text("Create a new page"), TextInputField(label: "Page name")],
    );
  }
}
