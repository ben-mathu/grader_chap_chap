import 'dart:io';

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
  String? imagePath;
  dynamic grade;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.max);
    controller?.initialize().then((value) {
      if (!mounted) {
        return;
      }
    });
  }

  void _processImage() async {
    // debugPrint('_processImage: Processing image...');
    final dynamic results = await widget.service
        .gradePaper(widget.indexNumber, widget.subject, imagePath??'', widget.url);
    // debugPrint('_processImage: $grade');
    setState(() {
      grade = results['grade'];
    });
    print('Grade: $grade');
  }

  void _clear() {
    setState(() {
      imagePath = null;
      grade = null;
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
            aspectRatio: controller?.value.aspectRatio ?? 1,
            child: CameraPreview(controller!),
          ),
        ),
        if (imagePath != null) Image.file(File(imagePath??'')),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (grade != null)
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                        child: SizedBox(
                            child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Results',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start),
                            const Divider(
                              color: Colors.black,
                            ),
                            Text('Index Number: ${widget.indexNumber}'),
                            Text("Results: ${grade['total_marks']}"),
                          ],
                        ),
                      ),
                    ))),
                  )),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (imagePath == null)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: IconButton(
                            color: Colors.amberAccent,
                            onPressed: () async {
                              try {
                                final image = await controller!.takePicture();
                                setState(() {
                                  imagePath = image.path;
                                });
                              } catch (e) {
                                print(e);
                              }
                            },
                            icon: const Icon(Icons.camera),
                          ),
                        ),
                      if (imagePath != null)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                _processImage();
                                // debugPrint('Tapping Submit');
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      const SizedBox(
                        width: 10,
                      ),
                      if (imagePath != null)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                _clear();
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        )
                    ],
                  ),
                ))
          ],
        )
      ],
    ));
  }
}
