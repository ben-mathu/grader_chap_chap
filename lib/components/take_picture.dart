import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grader_chap_chap/services/app_services.dart';

class TakePictureScreen extends StatefulWidget {
  TakePictureScreen(
      {super.key,
      required this.camera,
      required this.title,
      required this.indexNumber,
      required this.subject,
      required this.url});

  final String title;
  final CameraDescription camera;

  final String indexNumber;
  final String subject;
  final String url;

  final ApiService service = ApiService();

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

  Future<void> _processImage(String imagePath) async {
    setState(() {
      imagePath = imagePath;
    });
    final dynamic grade = await widget.service
        .gradePaper(widget.indexNumber, widget.subject, imagePath, widget.url);
    debugPrint(grade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          constraints: const BoxConstraints.expand(),
          child: AspectRatio(
            aspectRatio: controller?.value.aspectRatio ?? 0,
            child: CameraPreview(controller!),
          ),
        ),
        ElevatedButton.icon(
            onPressed: () async {
              try {
                final image = await controller!.takePicture();
                _processImage(image.path);
              } catch (e) {
                print(e);
              }
            },
            icon: const Icon(Icons.camera),
            label: const Text(''))
      ],
    ));
  }
}
