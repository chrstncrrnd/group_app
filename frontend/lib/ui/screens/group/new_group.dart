import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/services/group_creation.dart';
import 'package:group_app/ui/widgets/alert_dialog.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/next_button.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/validators.dart';
import 'package:image_picker/image_picker.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  String? _groupName;
  String? _groupDescription;

  final ImagePicker _picker = ImagePicker();

  File? _icon;

  Widget icon(double size) {
    if (_icon == null) {
      return Icon(
        Icons.group,
        size: size,
        color: Colors.white,
      );
    } else {
      return Image.file(
        _icon!,
        fit: BoxFit.cover,
      );
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text("Create a new group"),
        centerTitle: true,
      ),
      body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                GestureDetector(
                  child: BasicCircleAvatar(
                    radius: 50,
                    child: icon(50),
                  ),
                  onTap: () => showAdaptiveActionSheet(
                      context: context,
                      actions: [
                        BottomSheetAction(
                            title: const Text("Photo library"),
                            onPressed: (ctx) async {
                              var file = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxHeight: 400,
                                  maxWidth: 400);
                              if (file != null) {
                                setState(() {
                                  _icon = File(file.path);
                                });
                              }
                              Navigator.of(context).pop();
                            }),
                        BottomSheetAction(
                            title: const Text("Camera"),
                            onPressed: (ctx) async {
                              var file = await _picker.pickImage(
                                  source: ImageSource.camera,
                                  maxHeight: 400,
                                  maxWidth: 400);
                              if (file != null) {
                                setState(() {
                                  _icon = File(file.path);
                                });
                              }

                              Navigator.of(context).pop();
                            })
                      ],
                      cancelAction: CancelAction(title: const Text("Cancel"))),
                ),
                TextInputField(
                  label: "Name",
                  onChanged: (val) => _groupName = val,
                  validator: validateGroupName,
                ),
                TextInputField(
                  label: "Description",
                  onChanged: (val) => _groupDescription = val,
                  minLines: 3,
                  validator: validateGroupDescription,
                ),
                const SizedBox(
                  height: 40,
                ),
                NextButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return "Please check all of the fields";
                    }
                    var res = await createGroup(
                        name: _groupName, description: _groupDescription);
                    return res;
                  },
                  after: (res) {
                    if (res != null) {
                      showAdaptiveDialog(context,
                          title: const Text("An error occurred"),
                          content: Text(res),
                          actions: const [Text("Ok")]);
                    }
                    context.pop();
                  },
                )
              ],
            ),
          )),
    );
  }
}
