import 'package:flutter/material.dart';
import 'package:grader_chap_chap/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  /// Fetches all students
  Future<List<dynamic>> fetchStudents(String baseUrl) async {
    final url = Uri.parse('$baseUrl${Constants.studentsEndpoint}');
    final response = await http.get(url,
        headers: {"HttpHeaders.contentTypeHeader": "application/json"});

    debugPrint(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Could not get students');
    }
  }

  /// Fetches all subjects
  Future<List<dynamic>> fetchSubjects(String baseUrl) async {
    final Uri uri = Uri.parse('$baseUrl${Constants.subjectsEndpoint}');

    final response = await http.get(uri,
        headers: {"HttpHeaders.contentTypeHeader": "application/json"});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Could not retrieve subjects');
    }
  }

  Future<dynamic> gradePaper(String indexNumber, String subject,
      String imagePath, String baseUrl) async {
    debugPrint('Image path: $imagePath');

    final Uri url = Uri.parse('$baseUrl${Constants.gradingEndpoint}');
    final request = http.MultipartRequest('POST', url);
    request.headers['HttpHeaders.contentTypeHeader'] = 'application/json';
    request.fields['index_no'] = indexNumber;
    request.fields['subject'] = subject;
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Could not grade');
    }
  }
}
