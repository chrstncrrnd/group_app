import 'dart:io';

import 'package:flutter/material.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/ui/screens/camera/custom_camera.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/ui/screens/home/groups/pages/page/new_post/submit_new_post.dart';

class TakeNewPostScreen extends StatelessWidget {
  const TakeNewPostScreen({super.key, required this.inPage});

  final GroupPage inPage;

  void _onTakePicture(File file, BuildContext context) {
    GoRouter.of(context).go("/submit_new_post",
        extra: SubmitNewPostExtra(page: inPage, post: file));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomCamera(onTakePicture: (file) => _onTakePicture(file, context)),
          Positioned(left: 0, top: 0, child: _topControls(context)),
        ],
      ),
    );
  }

  Widget _topControls(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: context.pop, icon: const Icon(Icons.close_rounded))
      ],
    );
  }
}
