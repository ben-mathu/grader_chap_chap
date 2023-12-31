import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';

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
  CustomPaint? _customPaint;
  String? _text;
  late String _platformVersion = 'Unknown ';

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await FlutterMobileVision.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  final int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  final bool _autoFocusOcr = true;
  final bool _torchOcr = false;
  final bool _multipleOcr = false;
  final bool _waitTapOcr = false;
  final bool _showTextOcr = true;
  Size? _previewOcr;
  List<OcrText> _textsOcr = [];

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

    FlutterMobileVision.start().then((previewSizes) => setState(() {
          _previewOcr = previewSizes[_cameraOcr]!.first;
        }));
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      imagePath = imagePath;
    });

    List<OcrText> texts = [];
    Size scanPreviewOcr = _previewOcr ?? FlutterMobileVision.PREVIEW;

    try {
      texts = await FlutterMobileVision.read(
          flash: _torchOcr,
          autoFocus: _autoFocusOcr,
          multiple: _multipleOcr,
          waitTap: _waitTapOcr,
          forceCloseCameraOnTap: false,
          imagePath: imagePath,
          showText: _showTextOcr,
          preview: _previewOcr ?? FlutterMobileVision.PREVIEW,
          scanArea: Size(scanPreviewOcr.width - 20, scanPreviewOcr.height - 20),
          camera: _cameraOcr,
          fps: 2.0);
    } on Exception {
      texts.add(OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;
    setState(() {
      _textsOcr = texts;

      for (var textOcr in _textsOcr) {
        print(textOcr);
      }
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
