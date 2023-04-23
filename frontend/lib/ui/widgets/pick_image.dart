import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PickImage {
  final ImagePicker _picker = ImagePicker();

  Future<ImageSource?> _getImageSource(BuildContext context) async {
    ImageSource? imageSource;
    await showAdaptiveActionSheet(
        context: context,
        actions: [
          BottomSheetAction(
              title: const Text("Photo library"),
              onPressed: (ctx) {
                imageSource = ImageSource.gallery;
                Navigator.of(context).pop();
              }),
          BottomSheetAction(
              title: const Text("Camera"),
              onPressed: (ctx) {
                imageSource = ImageSource.camera;
                Navigator.of(context).pop();
              })
        ],
        cancelAction: CancelAction(title: const Text("Cancel")));

    return imageSource;
  }

  Future<File?> _chooseImage(ImageSource imageSource) async {
    var file = await _picker.pickImage(source: imageSource);
    return file == null ? null : File(file.path);
  }

  Future<File?> _cropImage(File image, CropAspectRatio aspectRatio,
      int maxWidth, int maxHeight) async {
    CroppedFile? f = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: aspectRatio,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          // need to do this better
          AndroidUiSettings(
              backgroundColor: Colors.black,
              toolbarTitle: "Crop image",
              toolbarColor: Colors.white,
              cropGridColor: Colors.white,
              statusBarColor: Colors.white)
        ]);
    if (f == null) {
      return null;
    }
    return File(f.path);
  }

  Future<File?> pickImage(
      {required BuildContext context,
      CropAspectRatio aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1),
      int maxHeight = 400,
      int maxWidth = 400}) async {
    var imageSource = await _getImageSource(context);
    if (imageSource == null) {
      return null;
    }

    var file = await _chooseImage(imageSource);
    if (file == null) {
      return null;
    }

    var icon = await _cropImage(file, aspectRatio, maxWidth, maxHeight);
    return icon;
  }
}
