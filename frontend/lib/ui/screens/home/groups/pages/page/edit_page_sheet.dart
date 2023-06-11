import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/services/group/group_update.dart';
import 'package:group_app/ui/widgets/adaptive_dialog.dart';
import 'package:group_app/ui/widgets/alert.dart';
import 'package:group_app/ui/widgets/next_button.dart';
import 'package:group_app/ui/widgets/progress_indicator_button.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/validators.dart';

class EditPageSheet extends StatefulWidget {
  const EditPageSheet({super.key, required this.group, required this.page});

  final Group group;
  final GroupPage page;

  @override
  State<EditPageSheet> createState() => _EditPageSheetState();
}

class _EditPageSheetState extends State<EditPageSheet> {
  late String _newPageName;

  @override
  void initState() {
    _newPageName = widget.page.name;
    super.initState();
  }

  Future<String?> _saveChanges() async {
    if (_newPageName == widget.page.name) {
      return null;
    }
    var newNameValid = validatePageName(_newPageName);
    if (newNameValid != null) {
      return newNameValid;
    }
    return await updatePage(
        pageName: _newPageName,
        pageId: widget.page.id,
        groupId: widget.page.groupId);
  }

  void _after(String? res) {
    if (res != null) {
      showAlert(context, title: "Couldn't update page", content: res);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            "Edit page",
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          TextInputField(
            label: "Page name",
            initialValue: widget.page.name,
            onChanged: (val) => _newPageName = val,
          ),
          const SizedBox(
            height: 20,
          ),
          NextButton(
            onPressed: _saveChanges,
            after: _after,
          ),
          const Divider(
            indent: 20,
            endIndent: 20,
            color: Color.fromARGB(52, 255, 255, 255),
            height: 100,
          ),
          _deleteButton(context)
        ],
      ),
    );
  }

  Widget _deleteButton(BuildContext context) {
    return TextButton.icon(
        style: const ButtonStyle(
            backgroundColor:
                MaterialStatePropertyAll(Color.fromARGB(255, 151, 17, 17))),
        onPressed: () async {
          await showAdaptiveDialog(context,
              title: const Text("Are you sure you want to delete this page?"),
              content: const Text(
                  "You won't be able to recover any posts made in this page"),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                    onPressed: () => context.pop(),
                    child: const Text("Cancel")),
                ProgressIndicatorButton(
                    progressIndicatorHeight: 15,
                    progressIndicatorWidth: 15,
                    onPressed: () async {
                      try {
                        await deletePage(
                            groupId: widget.page.groupId,
                            pageId: widget.page.id);
                      } catch (e) {
                        await showAlert(context,
                            title:
                                "Something went wrong while deleting this page");
                        log("Error while deleting page", error: e);
                      }
                    },
                    afterPressed: (_) {
                      context.pop();
                      context.go("/groups");
                    },
                    child: const Text("Delete"))
              ]);
        },
        icon: const Icon(Icons.delete),
        label: const Text("Delete group"));
  }
}
