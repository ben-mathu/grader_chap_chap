import 'package:grader_chap_chap/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  /// Fetches all students
  Future<List<dynamic>> fetchStudents(String baseUrl) async {
    try {
      final url = Uri.parse('$baseUrl${Constants.studentsEndpoint}');
      final response = await http.get(url,
          headers: {"HttpHeaders.contentTypeHeader": "application/json"});

      // debugPrint(response.body);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Could not get students');
      }
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception('Could not get students');
    }
  }

  /// Fetches all subjects
  Future<List<dynamic>> fetchSubjects(String baseUrl) async {
    try {
      final Uri uri = Uri.parse('$baseUrl${Constants.subjectsEndpoint}');

      final response = await http.get(uri,
          headers: {"HttpHeaders.contentTypeHeader": "application/json"});

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Could not retrieve subjects');
      }
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception('Could not retrieve subjects');
    }
  }

  Future<Map<String, dynamic>> gradePaper(String indexNumber, String subject,
      String imagePath, String baseUrl) async {
    try {
      print('Image path: $imagePath');

      final Uri url = Uri.parse('$baseUrl${Constants.gradingEndpoint}');
      var request = http.MultipartRequest('POST', url);
      request.headers['HttpHeaders.contentTypeHeader'] = 'application/json';
      final data = {'index_no': indexNumber, 'subject': subject};
      request = jsonToFormData(request, data);
      request.fields['index_no'] = indexNumber;
      request.fields['subject'] = subject;
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Response ${response.body}');

      if (response.statusCode == 201) {
        // debugPrint(response.body);
        return json.decode(response.body);
      } else {
        throw Exception('Could not grade');
      }
    } on Exception catch (e) {
      print(e.toString());
      throw Exception('Could not grade');
    }
  }

  jsonToFormData(http.MultipartRequest request, Map<String, dynamic> data) {
    for (var key in data.keys) {
      request.fields[key] = data[key].toString();
    }
    return request;
  }

  Future<dynamic> saveGrades(
      int totalMarks, int subject, String baseUrl) async {
    final Uri uri = Uri.parse('$baseUrl${Constants.gradesEndpoint}');

    final data = {"grade": totalMarks, "subject": subject};

    final response = await http.post(uri,
        headers: {"Content-Type": "application/json"}, body: json.encode(data));

    try {
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Could not retrieve subjects');
      }
    } on Exception catch (e) {
      print(e.toString());
      throw Exception('Could not grade');
    }
  }
}
