import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/group/group_update.dart';
import 'package:group_app/ui/widgets/alert_dialog.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/next_button.dart';
import 'package:group_app/ui/widgets/pick_image.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/constants.dart';
import 'package:group_app/utils/max.dart';
import 'package:group_app/utils/validators.dart';
import 'package:image_cropper/image_cropper.dart';

class EditGroupScreen extends StatefulWidget {
  const EditGroupScreen({super.key, required this.initialGroupState});

  final Group initialGroupState;

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final iconSize = 50.0;

  String? _newGroupName;
  String? _newGroupDescription;

  File? _icon;
  String? _iconDlUrl;
  bool _removeIcon = false;

  File? _banner;
  String? _bannerDlUrl;
  bool _removeBanner = false;

  bool _firstTimeBuilding = true;

  Widget banner() {
    if (_banner != null) {
      return Image.file(
        _banner!,
        fit: BoxFit.cover,
      );
    } else if (_bannerDlUrl != null) {
      return Image.network(
        _bannerDlUrl!,
        fit: BoxFit.cover,
      );
    } else {
      return Icon(
        Icons.groups_2,
        size: 50,
        color: Colors.white.withOpacity(0.6),
      );
    }
  }

  Widget icon(double size) {
    if (_icon != null) {
      return Image.file(
        _icon!,
        fit: BoxFit.cover,
      );
    } else if (_iconDlUrl != null) {
      return Image.network(
        _iconDlUrl!,
        fit: BoxFit.cover,
      );
    } else {
      return Icon(
        Icons.group,
        size: size,
        color: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_firstTimeBuilding) {
      _iconDlUrl = widget.initialGroupState.iconDlUrl;
      _bannerDlUrl = widget.initialGroupState.bannerDlUrl;
      _firstTimeBuilding = false;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit group"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      // the actual banner height is too much so we want it to be
                      //  a bit smaller so we multiply by 0.8
                      height: bannerHeight.toDouble() * 0.8,
                      width: Max.width(context),
                      child: banner(),
                    ),
                    onTap: () async {
                      var newBanner = await pickImage(
                          context: context,
                          aspectRatio:
                              const CropAspectRatio(ratioX: 4, ratioY: 3),
                          maxHeight: bannerHeight,
                          maxWidth: bannerWidth);

                      if (newBanner != null) {
                        setState(() {
                          _banner = newBanner;
                          _bannerDlUrl = null;
                          _removeBanner = false;
                        });
                      }
                    }),
                if (_banner != null || _bannerDlUrl != null)
                  Positioned(
                      left: 0,
                      bottom: 0,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.black.withOpacity(0.7))),
                        child: const Text(
                          "Remove banner",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => setState(() {
                          _banner = null;
                          _bannerDlUrl = null;
                          _removeBanner = true;
                        }),
                      )),
                Positioned(
                  bottom: -iconSize,
                  child: GestureDetector(
                    child: BasicCircleAvatar(
                        radius: iconSize, child: icon(iconSize)),
                    onTap: () async {
                      var newIcon = await pickImage(
                          context: context,
                          aspectRatio:
                              const CropAspectRatio(ratioX: 1, ratioY: 1),
                          maxHeight: 200,
                          maxWidth: 200);

                      if (newIcon != null) {
                        setState(() {
                          _icon = newIcon;
                          _iconDlUrl = null;
                          _removeIcon = false;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: iconSize,
            ),
            if (_icon != null || _iconDlUrl != null)
              TextButton(
                  onPressed: () {
                    setState(() {
                      _icon = null;
                      _iconDlUrl = null;
                      _removeIcon = true;
                    });
                  },
                  child: const Text("Remove icon")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  TextInputField(
                    validator: validateGroupName,
                    label: "Group name",
                    onChanged: (val) => _newGroupName = val,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextInputField(
                    validator: validateGroupDescription,
                    label: "Group description",
                    minLines: 3,
                    maxLines: 5,
                    onChanged: (val) => _newGroupDescription = val,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            NextButton(
              text: "Update",
              onPressed: () async {
                if (widget.initialGroupState.name == _newGroupName) {
                  _newGroupName = null;
                }
                if (widget.initialGroupState.description ==
                    _newGroupDescription) {
                  _newGroupDescription = null;
                }
                return await updateGroup(
                  groupId: widget.initialGroupState.id,
                  banner: _banner,
                  description: _newGroupDescription,
                  groupName: _newGroupName,
                  icon: _icon,
                  removeBanner: _removeBanner,
                  removeIcon: _removeIcon,
                );
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