import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:group_app/main.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraDescription firstCamera = cameras.first;

  @override
  void initState() async {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
