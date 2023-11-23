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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF78C1B)),
        useMaterial3: true,
      ),
      home: HomePage(title: 'Grader Chap Chap'),
      debugShowCheckedModeBanner: false,
    );
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
  List<dynamic> subjectsDynamic = [];

  String selectedIndexNumber = '';
  String selectedSubject = '';
  String url = Constants.baseUrl;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _openCamera() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TakePictureScreen(
            title: "",
            camera: cameras!.first,
            indexNumber: selectedIndexNumber,
            subject: selectedSubject,
            subjectId: _getSubjectId(),
            url: url)));
  }

  int _getSubjectId() {
    for (var subject in subjectsDynamic) {
      if (subject['name'] == selectedSubject) return subject['id'];
    }

    return 0;
  }

  void _fetchData() async {
    List<dynamic> students = await widget.service.fetchStudents(url);
    debugPrint('Students: $students');
    widget.studentIdList.clear();
    for (var student in students) {
      widget.studentIdList.add(student['index_no']);
    }
    debugPrint('Student ID List: ${widget.studentIdList.length}');

    // Fetch subject
    List<dynamic> subjectObjList = await widget.service.fetchSubjects(url);
    setState(() {
      subjectsDynamic = subjectObjList;
    });
    List<String> subjectList = [];
    for (var subject in subjectObjList) {
      subjectList.add(subject['name']);
    }

    setState(() {
      subjects = subjectList;
    });
  }

  void _useImage() {}

  static String _displayIndexNumbersForOptions(String indexNumber) =>
      indexNumber;
  static String _displaySubjectNameForOptions(String subjectName) =>
      subjectName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  onChanged: (String value) => {
                    setState(() {
                      url = value;
                    })
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Configure URL (temporary)',
                      hintText: 'localhost:8000'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Autocomplete<String>(
                    displayStringForOption: _displayIndexNumbersForOptions,
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextField(
                        decoration: const InputDecoration(
                            label: Text('Index Number'),
                            hintText: '001',
                            border: OutlineInputBorder()),
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (widget.studentIdList.isEmpty) {
                        _fetchData();
                      }
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return widget.studentIdList.where((String indexNumber) =>
                          indexNumber
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
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Autocomplete<String>(
                    displayStringForOption: _displaySubjectNameForOptions,
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextField(
                        decoration: const InputDecoration(
                            label: Text('Subject'),
                            hintText: 'Chemistry',
                            border: OutlineInputBorder()),
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (subjects.isEmpty) {
                        _fetchData();
                      }
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openCamera,
                      label: const Text('Take Picture'),
                      icon: const Icon(Icons.camera),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton.icon(
                      onPressed: _useImage,
                      label: const Text('Upload Photo'),
                      icon: const Icon(Icons.file_copy),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                    ),
                  ],
                )
              ]),
            )));
  }
}
