import 'dart:developer';
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
  bool _pfpUpdated = false;

  CurrentUser? _currentUser;

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

  Future<CurrentUser?> _future() async {
    _currentUser ??= await CurrentUser.getCurrentUser();
    return _currentUser;
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
          future: _future(),
          builder: (context, data) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(children: [
                GestureDetector(
                  child: BasicCircleAvatar(
                      radius: 50,
                      child: pfp(50, url: _pfpUpdated ? null : data?.pfpDlUrl)),
                  onTap: () async {
                    var newPfp = await pickImage(
                        context: context,
                        aspectRatio:
                            const CropAspectRatio(ratioX: 1, ratioY: 1),
                        maxHeight: 400,
                        maxWidth: 400);

                    if (newPfp != null) {
                      _pfpUpdated = true;
                      _pfp = newPfp;
                      setState(() {});
                    }
                  },
                ),
                if (_pfp != null || (data?.pfpDlUrl != null && !_pfpUpdated))
                  TextButton(
                      onPressed: () {
                        _pfp = null;
                        _pfpUpdated = true;
                        setState(() {});
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
                    if (data?.name == _newName) {
                      _newName = null;
                    }
                    if (data?.username == _newUsername) {
                      _newUsername = null;
                    }
                    var rm = _pfpUpdated && _pfp == null;
                    return await updateProfile(
                        name: _newName,
                        username: _newUsername,
                        pfp: _pfp,
                        removeCurrentPfp: rm);
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
            );
          }),
    );
  }
}
