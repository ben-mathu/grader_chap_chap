
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';

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
  CustomPaint? _customPaint;
  String? _text;

  void _processImage(XFile image) async {
    setState(() {
      imagePath = image.path;
    });

    List<OcrText> texts = [];

    try {
      texts = await FlutterMobileVision.read(
        flash: false,
        autoFocus: true,
        multiple: true,
        showText: true,
        preview: const Size(200, 200),
        camera: FlutterMobileVision.CAMERA_BACK
      );
    } on Exception {
      texts.add(OcrText('Failed to recognize text.'));
    }

    print('Text $texts');

    // final inputImage = InputImage.fromFilePath(image.path);
    // final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    // final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    // String text = recognizedText.text;
    // print('Recognized text: $text');

    // for (TextBlock block in recognizedText.blocks) {
    //   final Rect rect = block.boundingBox;
    //   final List<Point<int>> cornerPoints = block.cornerPoints;
    //   final String text = block.text;
    //   print('Text generated: $text');
    //   final List<String> languages = block.recognizedLanguages;
    //   print(languages);
    //
    //   for (TextLine line in block.lines) {
    //     print('Text generated: ${line.text}');
    //     for (TextElement element in line.elements) {
    //       print('Text generated: ${element.text}');
    //     }
    //   }
    // }

    // if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
    //   final painter = TextRecognizerPainter(
    //     recognizedText,
    //       inputImage.metadata!.size,
    //       inputImage.metadata!.rotation,
    //       CameraLensDirection.back
    //   );
    //
    //   _customPaint = CustomPaint(painter: painter);
    // } else {
    //   _text = 'Recognized text:\n\n${recognizedText.text}';
    //   print(_text);
    //   // TODO: set _customPaint to draw boundingRect on top of image
    //   _customPaint = null;
    // }

    // textRecognizer.close();
  }

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