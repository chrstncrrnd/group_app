import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/services/user.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/buttons/next_button.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';
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
              maxLines: 1,
              validator: validateName,
              initialValue: currentUser.name,
              label: "Name",
              onChanged: (val) => _newName = val.trim(),
            ),
            const SizedBox(
              height: 10,
            ),
            TextInputField(
              maxLines: 1,
              validator: validateUsername,
              initialValue: currentUser.username,
              label: "Username",
              onChanged: (val) => _newUsername = val.trim(),
            ),
            const SizedBox(
              height: 10,
            ),
            NextButton(
              text: "Update",
              onPressed: () async {
                _newName = _newName?.trim();
                _newUsername = _newUsername?.trim();

                if (currentUser.name == _newName) {
                  _newName = null;
                }
                if (currentUser.username == _newUsername) {
                  _newUsername = null;
                }
                _newName = _newName?.trim();
                _newUsername = _newUsername?.trim();
                return await updateProfile(
                    name: _newName,
                    username: _newUsername,
                    pfp: _pfp,
                    removeCurrentPfp: _removePfp);
              },
              after: (res) {
                if (res != null) {
                  showAlert(context, title: "An error occurred", content: res);
                } else {
                  context.pop();
                }
              },
            ),
          ]),
        ));
  }
}
