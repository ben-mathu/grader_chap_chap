import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen(
      {super.key, required this.camera, required this.title});

  final String title;
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

  Future<void> _processImage(String imagePath) async {}

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
          child: ElevatedButton(
              onPressed: () async {
                try {
                  final image = await controller!.takePicture();
                  _processImage(image.path);
                } catch (e) {
                  print(e);
                }
              },
              child: const Text("Scan document")),
        )
      ],
    ));
  }
}
