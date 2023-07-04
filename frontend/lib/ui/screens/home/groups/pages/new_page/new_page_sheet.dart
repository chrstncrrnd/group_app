import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/group/group_update.dart';
import 'package:group_app/ui/widgets/buttons/next_button.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/validators.dart';

class NewPageSheet extends StatefulWidget {
  const NewPageSheet({super.key, required this.group});

  final Group group;

  @override
  State<NewPageSheet> createState() => _NewPageSheetState();
}

class _NewPageSheetState extends State<NewPageSheet> {
  String _pageName = "";

  Future<String?> _next() async {
    String? valid = validatePageName(_pageName);
    if (valid != null) {
      return valid;
    }

    await createPage(_pageName, widget.group.id);

    return null;
  }

  Future<void> _after(String? error) async {
    if (error != null) {
      await showAlert(context,
          title: "An error occurred while creating page", content: error);
    } else {
      context.pop();
    }
  }

  void _onChange(String newVal) {
    _pageName = newVal.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            "Create a new page",
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          TextInputField(
            label: "Page name",
            onChanged: _onChange,
          ),
          const SizedBox(
            height: 20,
          ),
          NextButton(
            onPressed: _next,
            after: _after,
          )
        ],
      ),
    );
  }
}
