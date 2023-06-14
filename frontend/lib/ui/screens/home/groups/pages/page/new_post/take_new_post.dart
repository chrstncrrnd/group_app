import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/ui/screens/camera/custom_camera.dart';
import 'package:go_router/go_router.dart';

class TakeNewPostScreen extends StatefulWidget {
  const TakeNewPostScreen({super.key, required this.inPage});

  final GroupPage inPage;

  @override
  State<TakeNewPostScreen> createState() => _TakeNewPostScreenState();
}

class _TakeNewPostScreenState extends State<TakeNewPostScreen> {
  File? _post;

  void _onTakePicture(File file) {
    _post = file;
  }

  @override
  Widget build(BuildContext context) {
    log("balls");
    return Stack(
      children: [
        CustomCamera(onTakePicture: _onTakePicture),
        Positioned(left: 0, top: 0, child: _topControls()),
      ],
    );
  }

  Widget _topControls() {
    return Row(
      children: [
        IconButton(
            onPressed: context.pop, icon: const Icon(Icons.close_rounded))
      ],
    );
  }
}
