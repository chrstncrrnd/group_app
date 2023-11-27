import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/services/posts.dart';
import 'package:group_app/ui/widgets/async/shimmer_loading_indicator.dart';
import 'package:group_app/ui/widgets/async/suspense.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/buttons/progress_indicator_button.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/max.dart';

class SubmitNewPostExtra {
  SubmitNewPostExtra({required this.page, required this.post});

  final GroupPage page;
  final File post;
}

class SubmitNewPostScreen extends StatelessWidget {
  const SubmitNewPostScreen({super.key, required this.extra});

  final SubmitNewPostExtra extra;

  Future<String?> postIt({required String caption}) async {
    return await createPost(
        page: extra.page, file: extra.post, caption: caption);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.replace("/take_new_post", extra: extra.page),
        ),
        title: const Text("New post"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 20,
            child: Container(
              // Idk why this works, but it does
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(extra.post)),
            ),
          ),
          Flexible(flex: 8, child: publish(context))
        ],
      ),
    );
  }

  Widget publish(BuildContext context) {
    String caption = "";
    return Column(
      children: [
        wherePosted(context),
        ProgressIndicatorButton(
          onPressed: () async => await postIt(caption: caption),
          afterPressed: (value) {
            if (value != null) {
              showAlert(context,
                  title: "An error occurred while creating the post",
                  content: value.toString());
            } else {
              context.pop();
            }
          },
          child: const Row(
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
        ),
        StatefulBuilder(builder: (context, setState) {
          return Container(
            width: Max.width(context),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Caption",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                    onTap: () async {
                      String c = await showModalBottomSheet(
                          backgroundColor: Colors.black,
                          showDragHandle: true,
                          useSafeArea: true,
                          isScrollControlled: true,
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: editCaptionModalSheetBuilder);
                      setState(
                        () => caption = c,
                      );
                    },
                    child: caption.isEmpty
                        ? const Text(
                            "Add...",
                            style: TextStyle(color: Colors.grey),
                          )
                        : Text(caption))
              ],
            ),
          );
        })
      ],
    );
  }

  Widget addCaptionButton(BuildContext context) {
    String caption = "";

    return StatefulBuilder(builder: (context, setState) {
      return Container(
        width: Max.width(context),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Caption",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
                onTap: () async {
                  String c = await showModalBottomSheet(
                      backgroundColor: Colors.black,
                      showDragHandle: true,
                      useSafeArea: true,
                      isScrollControlled: true,
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: editCaptionModalSheetBuilder);
                  setState(
                    () => caption = c,
                  );
                },
                child: caption.isEmpty
                    ? const Text(
                        "Add...",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Text(caption))
          ],
        ),
      );
    });
  }

  Widget editCaptionModalSheetBuilder(BuildContext context) {
    String caption = "";

    void close() {
      Navigator.of(context).pop(caption.trim());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add caption",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          TextInputField(
            autofocus: true,
            label: "Describe this post",
            minLines: 3,
            maxLines: 5,
            onChanged: (data) => caption = data,
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: TextButton(onPressed: close, child: const Text("Done")),
          )
        ],
      ),
    );
  }

  Widget wherePosted(BuildContext context) {
    Widget placeholder(BuildContext context) {
      const double iconRadius = 11;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerLoadingIndicator(
            child: BasicCircleAvatar(radius: iconRadius, child: Container()),
          ),
          const SizedBox(
            width: 10,
          ),
          const ShimmerLoadingIndicator(
            child: Text(
              "---------",
            ),
          ),
          const Text(
            "/",
            style: TextStyle(color: Colors.grey),
          ),
          ShimmerLoadingIndicator(
            child: Text(
              extra.page.name,
            ),
          )
        ],
      );
    }

    return Suspense<Group?>(
      future: extra.page.getGroup(useCache: true),
      placeholder: placeholder(context),
      builder: (context, data) {
        const TextStyle textStyle = TextStyle(color: Colors.grey);
        if (data == null) {
          return const Text(
            "Something went wrong...",
            style: textStyle,
          );
        }

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
    );
  }
}
