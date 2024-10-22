import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/services/group/group_creation.dart';
import 'package:groopo/ui/widgets/basic_circle_avatar.dart';
import 'package:groopo/ui/widgets/buttons/next_button.dart';
import 'package:groopo/ui/widgets/dialogs/alert.dart';
import 'package:groopo/ui/widgets/pick_image.dart';
import 'package:groopo/ui/widgets/text_input_field.dart';
import 'package:groopo/utils/validators.dart';
import 'package:image_cropper/image_cropper.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  String? _groupName;
  String? _groupDescription;

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
        title: const Text("New group"),
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
                  onTap: () async {
                    var icon = await pickImage(
                        context: context,
                        aspectRatio:
                            const CropAspectRatio(ratioX: 1, ratioY: 1),
                        maxHeight: 400,
                        maxWidth: 400);

                    if (icon != null) {
                      setState(() {
                        _icon = icon;
                      });
                    }
                  },
                ),
                TextInputField(
                  label: "Name",
                  onChanged: (val) => _groupName = val.trim(),
                  maxLines: 1,
                  validator: validateGroupName,
                ),
                TextInputField(
                  label: "Description",
                  onChanged: (val) => _groupDescription = val.trim(),
                  minLines: 3,
                  validator: validateGroupDescription,
                ),
                const SizedBox(
                  height: 40,
                ),
                NextButton(
                  text: "Create",
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return "Please double check the fields";
                    }
                    var res = await createGroup(
                        name: _groupName,
                        description: _groupDescription,
                        icon: _icon);
                    return res;
                  },
                  after: (res) {
                    if (res != null) {
                      showAlert(
                        context,
                        title: "An error occurred",
                        content: res,
                      );
                    } else {
                      context.pop();
                    }
                  },
                )
              ],
            ),
          )),
    );
  }
}
