import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/certification.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Map<String, dynamic>>> fetchQuestions() async {
    final res = await http.get(Uri.parse('$baseUrl/questions'));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load questions');
    }
  }

   static Future<List<Certification>> fetchCertifications() async {
    final response = await http.get(Uri.parse('$baseUrl/certifications'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => Certification.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load certifications');
    }
  }
}
