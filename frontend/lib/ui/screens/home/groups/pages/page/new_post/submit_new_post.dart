import 'dart:io';

import 'package:flutter/material.dart';
import 'package:group_app/models/page.dart';

class SubmitNewPostExtra {
  SubmitNewPostExtra({required this.page, required this.post});

  final GroupPage page;
  final File post;
}

class SubmitNewPostScreen extends StatelessWidget {
  const SubmitNewPostScreen({super.key, required this.extra});

  final SubmitNewPostExtra extra;

  @override
  Widget build(BuildContext context) {
    return Image.file(extra.post);
  }
}
