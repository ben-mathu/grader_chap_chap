import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grader_chap_chap/components/take_picture.dart';
import 'package:grader_chap_chap/services/app_services.dart';
import 'package:grader_chap_chap/utils/constants.dart';

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
        home: HomePage(title: 'Grader Chap Chap'));
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title});

  final String title;
  final ApiService service = ApiService();
  final List<String> studentIdList = [];

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List<String> subjects = [];

  String selectedIndexNumber = '';
  String selectedSubject = '';
  String url = Constants.baseUrl;

  void _openCamera() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TakePictureScreen(
            title: "",
            camera: cameras!.first,
            indexNumber: selectedIndexNumber,
            subject: selectedSubject,
            url: url)));
  }

  void _fetchData() async {
    List<dynamic> students = await widget.service.fetchStudents(url);
    debugPrint('Students: $students');
    for (var student in students) {
      widget.studentIdList.add(student['index_no']);
    }
    debugPrint('Student ID List: ${widget.studentIdList.length}');

    // Fetch subject
    List<dynamic> subjectObjList = await widget.service.fetchSubjects(url);
    for (var subject in subjectObjList) {
      subjects.add(subject['name']);
    }
  }

  static String _displayIndexNumbersForOptions(String indexNumber) =>
      indexNumber;
  static String _displaySubjectNameForOptions(String subjectName) =>
      subjectName;

  @override
  Widget build(BuildContext context) {
    _fetchData();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            TextField(
              onChanged: (String value) => {url = value},
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Configure URL (temporary)',
                  hintText: 'localhost:8000'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Autocomplete<String>(
                      displayStringForOption: _displayIndexNumbersForOptions,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return widget.studentIdList.where(
                            (String indexNumber) => indexNumber
                                .toString()
                                .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        selectedIndexNumber = selection;
                        debugPrint(
                            'You just selected ${_displayIndexNumbersForOptions(selection)}');
                      },
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Autocomplete<String>(
                    displayStringForOption: _displaySubjectNameForOptions,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return subjects.where((String subject) => subject
                          .toString()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String subjectSelection) {
                      selectedSubject = subjectSelection;
                      debugPrint(
                          'You just selected ${_displaySubjectNameForOptions(subjectSelection)}');
                    },
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
