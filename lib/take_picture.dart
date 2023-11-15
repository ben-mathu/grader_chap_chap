import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:camera_android/camera_android.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;
  @override
  State<StatefulWidget> createState() {
    return _TakePictureScreen();
  }
}

class _TakePictureScreen extends State<TakePictureScreen> {
  CameraController? controller;
  String imagePath = '';

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.max);
    controller?.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: CameraPreview(controller!),
            ),
          ),
          Center(
            child: ElevatedButton(onPressed: () async {
              try {
                final image = await controller!.takePicture();
                setState(() {
                  imagePath = image.path;
                });
              } catch(e) {
                print(e);
              }
            }, child: const Text("Scan document")),
          )
        ],
      )
    );
  }
}