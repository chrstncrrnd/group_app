import 'package:flutter/material.dart';
import 'package:group_app/ui/screens/camera/custom_camera.dart';

class NewPostScreen extends StatelessWidget {
  const NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomCamera(
        onTakePicture: (p0) {
        },
      ),
    );
  }
}
