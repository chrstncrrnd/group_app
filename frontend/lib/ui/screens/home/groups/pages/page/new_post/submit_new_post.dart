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
    const double iconSize = 27;
    return Suspense<Group>(
        future: extra.page.getGroup(),
        builder: (context, group) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () =>
                    context.replace("/take_new_post", extra: extra.page),
              ),
              title: const Text("New post"),
            ),
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(extra.post)),
                ),
                Positioned(
                  bottom: 0,
                  child: ProgressIndicatorButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.white),
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.black)),
                      onPressed: postIt,
                      afterPressed: (value) {
                        if (value != null) {
                          showAlert(context,
                              title:
                                  "An error occurred while creating the post",
                              content: value);
                        } else {
                          context.pop();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BasicCircleAvatar(
                                    radius: iconSize / 2,
                                    child: group!.icon(iconSize)),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  "Post",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: iconSize,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            AutoSizeText(
                              extra.page.name,
                              maxLines: 1,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      )),
                )
              ],
            ),
          );
        });
  }
}
