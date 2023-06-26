import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/post.dart';
import 'package:group_app/utils/max.dart';

class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.post});

  final Post post;

  Widget _sheetView() {
    return Column(
      children: [
        Text("${post.creatorId} in ${post.groupId}"),
        Center(child: Image.network(post.dlUrl))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        SizedBox(
          width: Max.width(context),
          height: Max.height(context),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                showDragHandle: true,
                isScrollControlled: true,
                useRootNavigator: true,
                useSafeArea: true,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return _sheetView();
                },
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.dlUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const Positioned(
          bottom: 5,
          left: 5,
          child: AutoSizeText(
            "@chrstncrrnd",
            overflow: TextOverflow.ellipsis,
            maxFontSize: 14,
            maxLines: 1,
            style: TextStyle(shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 10,
              )
            ]),
          ),
        ),
      ],
    );
  }
}
