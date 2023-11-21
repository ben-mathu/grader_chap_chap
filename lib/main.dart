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
        title: 'Grader Chap Chap',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
          useMaterial3: true,
        ),
        home: const HomePage(title: 'Grader Chap Chap'));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  void _openCamera() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            TakePictureScreen(title: "", camera: cameras!.first)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Student ID',
                        hintText: '001/90298493',
                        suffixIcon: Icon(Icons.arrow_drop_down)),
                  ),
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Subject',
                        hintText: 'Chemistry',
                        suffixIcon: Icon(Icons.arrow_drop_down)),
                  ),
                )),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _openCamera,
              label: const Text('Take Picture'),
              icon: const Icon(Icons.camera),
            ),
          ]),
        ));
  }
}
