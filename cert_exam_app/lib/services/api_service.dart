import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/certification.dart';
import 'auth_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await AuthStorage.saveToken(data['token']);
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to signup');
    }
  }

  static Future<List<dynamic>> fetchQuestionsByCertification(
    int certificationId, 
    String token,
  ) async {
    final url = Uri.parse(
      'http://localhost:3000/certifications/$certificationId/questions',
    );

    print('➡️ REQUEST URL: $url');
    print('➡️ certificationId: $certificationId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      },
      
    );

  

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load questions');
    }
  }
  

  static Future<int> startExam(int certificationId, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/exams/start'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'certificationId': certificationId}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data['attemptId'];
    } else {
      throw Exception(
          'Failed to start exam. Status: ${res.statusCode}, Body: ${res.body}');
    }
  }

  static Future<void> saveAnswer({
    required int attemptId,
    required int questionId,
    required String selectedOption,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exams/answer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'attemptId': attemptId,
        'questionId': questionId,
        'selectedOption': selectedOption,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Failed to save answer. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }



  static Future<List<Certification>> fetchCertifications() async {
    final token = (await AuthStorage.getToken())!;

    final response = await http.get(
      Uri.parse('$baseUrl/certifications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      final List<Certification> certs = [];

      for (final item in data) {
        try {
          if (item == null) continue;
          if (item['id'] == null) {
            print('Skipping certification with missing id: $item');
            continue;
          }
          certs.add(Certification.fromJson(item));
        } catch (e) {
          // Skip invalid items but log for investigation
          print('Skipping invalid certification item: $item — $e');
        }
      }

      return certs;
    } else {
      throw Exception('Failed to load certifications');
    }
  }
}
