import 'package:grader_chap_chap/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<List<dynamic>> fetchStudents() async {
    final url = Uri.parse(Constants.baseUrl + Constants.studentEndpoint);
    final response = await http.get(url, headers: {"HttpHeaders.contentTypeHeader": "application/json"});

    print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Could not get students');
    }
  }
}
