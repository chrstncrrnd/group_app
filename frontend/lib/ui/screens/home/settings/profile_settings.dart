import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/services/auth.dart';
import 'package:group_app/ui/widgets/alert_dialog.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/next_button.dart';
import 'package:group_app/ui/widgets/pick_image.dart';
import 'package:group_app/ui/widgets/suspense.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/validators.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String? _newName;
  String? _newUsername;

  File? _pfp;

  final PickImage _pickImage = PickImage();

  Widget pfp(double size, {String? url}) {
    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.cover,
      );
    } else if (_pfp == null) {
      return Icon(
        Icons.person,
        size: size,
        color: Colors.white,
      );
    } else {
      return Image.file(
        _pfp!,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update profile"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Suspense(
          future: CurrentUser.getCurrentUser(),
          builder: (context, data) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(children: [
                GestureDetector(
                  child: BasicCircleAvatar(
                      radius: 50, child: pfp(50, url: data?.pfpUrl)),
                  onTap: () async {
                    var newPfp = await _pickImage.pickImage(
                        context: context,
                        aspectRatio:
                            const CropAspectRatio(ratioX: 1, ratioY: 1),
                        maxHeight: 400,
                        maxWidth: 400);

                    if (newPfp != null) {
                      setState(() {
                        _pfp = newPfp;
                      });
                    }
                  },
                ),
                TextInputField(
                  validator: validateName,
                  label: "Name",
                  onChanged: (val) => _newName = val,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextInputField(
                  validator: validateUsername,
                  label: "Username",
                  onChanged: (val) => _newUsername = val,
                ),
                const SizedBox(
                  height: 10,
                ),
                NextButton(
                  text: "Update",
                  onPressed: () async {
                    if (data?.name == _newName) {
                      _newName = null;
                    }
                    if (data?.username == _newUsername) {
                      _newUsername = null;
                    }

                    return await updateProfile(
                        name: _newName, username: _newUsername, pfp: _pfp);
                  },
                  after: (res) {
                    if (res != null) {
                      showAdaptiveDialog(context,
                          title: const Text("An error occurred"),
                          content: Text(res),
                          actions: const [Text("Ok")]);
                    } else {
                      context.pop();
                    }
                  },
                )
              ]),
            );
          }),
    );
  }
}
