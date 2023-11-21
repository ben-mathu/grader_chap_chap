import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grader_chap_chap/take_picture.dart';

List<CameraDescription>? cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: TakePictureScreen(
            title: 'Grader Chap Chap', camera: cameras!.first));
  }
}
