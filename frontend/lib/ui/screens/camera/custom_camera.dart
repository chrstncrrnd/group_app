import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:group_app/main.dart';
import 'package:group_app/ui/widgets/pick_image.dart';
import 'package:group_app/utils/max.dart';
import 'package:image_picker/image_picker.dart';

class CustomCamera extends StatefulWidget {
  const CustomCamera({super.key, required this.onTakePicture});

  final Function(File picture) onTakePicture;

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _cameraInitialized = false;
  bool _rearCameraSelected = false;

  double _minZoom = 1;
  double _maxZoom = 1;

  final double _bottomIconSize = 60;

  @override
  void initState() {
    onNewCameraSelected(cameras.first);
    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    log("Disposed camera");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraController;

    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(controller.description);
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final prev = _cameraController;
    final CameraController newController = CameraController(
        cameraDescription, ResolutionPreset.max,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);

    await prev?.dispose();

    if (mounted) {
      setState(() {
        _cameraController = newController;
      });
    }

    // camera controller should not be null
    _cameraController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    try {
      await _cameraController!.initialize();
    } on CameraException catch (e) {
      log("An error occurred while initializing the camera", error: e);
      return;
    }
    _cameraController!.getMaxZoomLevel().then((value) => _maxZoom = value);
    _cameraController!.getMinZoomLevel().then((value) => _minZoom = value);

    if (mounted) {
      setState(() {
        _cameraInitialized = _cameraController!.value.isInitialized;
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      var file = await _cameraController!.takePicture();
      widget.onTakePicture(File(file.path));
    } on CameraException catch (e) {
      log("An error occurred while taking a picture", error: e);
    }
  }

  Widget _gallerySelectButton() {
    return IconButton(
        onPressed: () async {
          _cameraController?.dispose().then((value) {
            log("camera disposed");
            _cameraInitialized = false;
          });
          var file = await pickImageFromSource(
              imageSource: ImageSource.gallery,
              context: context,
              shouldCrop: false);
          if (file == null) {
            log("An error occurred while picking an image from image gallery in custom camera");
            return;
          }
          onNewCameraSelected(cameras.first)
              .then((value) => _cameraInitialized = true);
          widget.onTakePicture(file);
        },
        icon: Icon(
          Icons.photo,
          size: _bottomIconSize / 1.5,
        ));
  }

  Widget _takePictureButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: _bottomIconSize,
        height: _bottomIconSize,
        decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white, width: 7, style: BorderStyle.solid)),
      ),
    );
  }

  Widget _switchCameraButton() {
    return IconButton(
        onPressed: () {
          setState(() {
            _cameraInitialized = false;
          });
          onNewCameraSelected(
            cameras[_rearCameraSelected ? 0 : 1],
          );
          setState(() {
            _rearCameraSelected = !_rearCameraSelected;
          });
        },
        icon: Icon(
          Icons.cameraswitch_outlined,
          size: _bottomIconSize / 1.5,
        ));
  }

  Widget _cameraView(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onScaleUpdate: (details) async {
            // just calling it dragIntensity for now, you can call it whatever you like.
            var dragIntensity = details.scale;
            if (dragIntensity < _minZoom) {
              _cameraController!.setZoomLevel(_minZoom);
            } else if (dragIntensity > 1 && dragIntensity < _maxZoom) {
              // self-explanatory, that if the maxZoomLevel exceeds, you will get an error (greater than one is given to details when you zoom-in/pinch-out).
              _cameraController!.setZoomLevel(dragIntensity);
            } else {
              // if it does exceed, you can provide the maxZoomLevel instead of dragIntensity (this block is executed whenever you zoom-in/pinch-out more than the max zoom level).
              _cameraController!.setZoomLevel(_maxZoom);
            }
          },
          child: AspectRatio(
            aspectRatio: 1 / _cameraController!.value.aspectRatio,
            child: _cameraController!.buildPreview(),
          ),
        ),
        Positioned(
            bottom: 10,
            width: Max.width(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _gallerySelectButton(),
                _takePictureButton(),
                _switchCameraButton()
              ],
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _cameraInitialized ? _cameraView(context) : Container();
  }
}
