import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/page.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/ui/screens/home/groups/pages/page/new_post/submit_new_post.dart';
import 'package:path_provider/path_provider.dart';

class TakeNewPostScreen extends StatelessWidget {
  const TakeNewPostScreen({super.key, required this.inPage});

  final GroupPage inPage;

  void _onTakePicture(File file, BuildContext context) {
    context.replace(
      "/submit_new_post",
      extra: SubmitNewPostExtra(page: inPage, post: file),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: context.pop, icon: const Icon(Icons.close_rounded))),
      body: Center(
          child: CameraAwesomeBuilder.awesome(
        sensorConfig: SensorConfig.single(
          aspectRatio: CameraAspectRatios.ratio_4_3,
          flashMode: FlashMode.auto,
          sensor: Sensor.position(SensorPosition.back),
          zoom: 0.0,
        ),
        enablePhysicalButton: true,
        onMediaTap: (mediaCapture) {
          var req = mediaCapture.captureRequest as SingleCaptureRequest;
          var path = req.file!.path;
          _onTakePicture(File(path), context);
        },
        saveConfig: SaveConfig.photo(
          pathBuilder: (sensors) async {
            final Directory tempDir = await getTemporaryDirectory();
            final testDir = await Directory(
              '${tempDir.path}/groopo_camerawesome',
            ).create(recursive: true);
            final String filePath =
                '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
            return SingleCaptureRequest(filePath, sensors.first);
          },
        ),
      )),
    );
  }
}
