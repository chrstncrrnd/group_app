
import 'package:flutter/material.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/page.dart';
import 'package:groopo/services/group/group_update.dart';
import 'package:groopo/ui/widgets/buttons/next_button.dart';
import 'package:groopo/ui/widgets/dialogs/alert.dart';
import 'package:groopo/ui/widgets/text_input_field.dart';
import 'package:groopo/utils/validators.dart';

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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Edit page",
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          TextInputField(
            maxLines: 1,
            label: "Page name",
            initialValue: widget.page.name,
            onChanged: (val) => _newPageName = val.trim(),
          ),
          const SizedBox(
            height: 20,
          ),
          NextButton(
            onPressed: _saveChanges,
            after: _after,
          ),
        ],
      ),
    );
  }
}
