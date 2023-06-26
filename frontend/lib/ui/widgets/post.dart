import 'package:flutter/material.dart';
import 'package:group_app/models/post.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Image.network(post.dlUrl);
  }
}
