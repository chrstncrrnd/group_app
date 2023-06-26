import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class GridPostView extends StatelessWidget {
  const GridPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GridView.builder(
        itemCount: 30,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1 / 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemBuilder: (context, index) {
          return dummyPost(context);
        },
      ),
    );
  }

  Widget dummyPost(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            "https://images.unsplash.com/photo-1659283552244-730da7ac52d4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8YmxhY2slMjBjb3VudHJ5JTIwbmV3JTIwcm9hZHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60",
            fit: BoxFit.cover,
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
