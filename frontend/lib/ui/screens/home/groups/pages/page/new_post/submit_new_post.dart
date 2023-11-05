import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/services/posts.dart';
import 'package:group_app/ui/widgets/async/suspense.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/buttons/progress_indicator_button.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';

class SubmitNewPostExtra {
  SubmitNewPostExtra({required this.page, required this.post});

  final GroupPage page;
  final File post;
}

class SubmitNewPostScreen extends StatelessWidget {
  const SubmitNewPostScreen({super.key, required this.extra});

  final SubmitNewPostExtra extra;

  Future<String?> postIt() async {
    return await createPost(page: extra.page, file: extra.post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.replace("/take_new_post", extra: extra.page),
        ),
        title: const Text("New post"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              // Idk why this works, but it does
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(extra.post)),
            ),
          ),
          Expanded(flex: 1, child: _publishPostButton(context))
        ],
      ),
    );
  }

  Widget _publishPostButton(BuildContext context) {
    return ProgressIndicatorButton(
      onPressed: postIt,
      afterPressed: (value) {
        if (value != null) {
          showAlert(context,
              title: "An error occurred while creating the post",
              content: value);
        } else {
          context.pop();
        }
      },
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 40,
              ),
              AutoSizeText(
                "Publish",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              )
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Suspense<Group?>(
            future: extra.page.getGroup(useCache: true),
            builder: (context, data) {
              if (data == null) {
                return const Text(
                  "Something went wrong...",
                  style: TextStyle(color: Colors.grey),
                );
              }
              const TextStyle textStyle = TextStyle(color: Colors.grey);

              Group group = data;
              const double iconRadius = 11;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BasicCircleAvatar(
                      radius: iconRadius, child: group.icon(iconRadius * 2)),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    group.name,
                    style: textStyle,
                  ),
                  const Text(
                    "/",
                    style: textStyle,
                  ),
                  Text(
                    extra.page.name,
                    style: textStyle,
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
