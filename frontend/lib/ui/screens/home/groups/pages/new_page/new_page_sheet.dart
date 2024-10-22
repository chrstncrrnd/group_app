import 'package:flutter/material.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/services/group/group_update.dart';
import 'package:groopo/ui/widgets/buttons/next_button.dart';
import 'package:groopo/ui/widgets/dialogs/alert.dart';
import 'package:groopo/ui/widgets/text_input_field.dart';
import 'package:groopo/utils/validators.dart';

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
      Navigator.pop(context);
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
            autofocus: true,
            label: "Page name",
            onChanged: _onChange,
            maxLines: 1,
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
