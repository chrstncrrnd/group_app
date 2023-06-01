import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/services/user.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/ui/widgets/adaptive_dialog.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/next_button.dart';
import 'package:group_app/ui/widgets/pick_image.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String? _newName;
  String? _newUsername;

  File? _pfp;
  String? _pfpDlUrl;

  bool _firstTimeBuilding = true;

  bool _removePfp = false;

  Widget pfp(double size) {
    if (_pfp != null) {
      return Image.file(
        _pfp!,
        fit: BoxFit.cover,
      );
    } else if (_pfpDlUrl != null) {
      return Image.network(
        _pfpDlUrl!,
        fit: BoxFit.cover,
      );
    } else {
      return Icon(
        Icons.person,
        size: size,
        color: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser!;
    if (_firstTimeBuilding) {
      _pfpDlUrl = currentUser.pfpDlUrl;
      _firstTimeBuilding = false;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update profile"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(children: [
            GestureDetector(
              child: BasicCircleAvatar(radius: 50, child: pfp(50)),
              onTap: () async {
                var newPfp = await pickImage(
                    context: context,
                    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                    maxHeight: 200,
                    maxWidth: 200);

                if (newPfp != null) {
                  setState(() {
                    _pfp = newPfp;
                    _pfpDlUrl = null;
                    _removePfp = false;
                  });
                }
              },
            ),
            if (_pfp != null || _pfpDlUrl != null)
              TextButton(
                  onPressed: () {
                    setState(() {
                      _pfp = null;
                      _pfpDlUrl = null;
                      _removePfp = true;
                    });
                  },
                  child: const Text("Remove profile picture")),
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
                if (currentUser.name == _newName) {
                  _newName = null;
                }
                if (currentUser.username == _newUsername) {
                  _newUsername = null;
                }
                return await updateProfile(
                    name: _newName,
                    username: _newUsername,
                    pfp: _pfp,
                    removeCurrentPfp: _removePfp);
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
            ),
          ]),
        ));
  }
}
