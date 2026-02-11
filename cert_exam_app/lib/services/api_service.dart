import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/certification.dart';
import '../models/exam_attempt.dart'; 
import 'auth_storage.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api';

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
      String msg = 'Failed to login';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) msg = body['message'];
      } catch (_) {}
      throw Exception(msg);
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
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String msg = 'Failed to signup';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) msg = body['message'];
      } catch (_) {}
      throw Exception(msg);
    }
  }

  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode != 200) {
      String msg = 'Failed to process request';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) msg = body['message'];
      } catch (_) {}
      throw Exception(msg);
    }
  }

  static Future<void> changePassword(String currentPassword, String newPassword) async {
    final token = await AuthStorage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      String msg = 'Failed to change password';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) msg = body['message'];
      } catch (_) {}
      throw Exception(msg);
    }
  }

  static Future<List<dynamic>> fetchQuestionsByCertification(
    int certificationId, 
    String token,
  ) async {
    final url = Uri.parse(
      '$baseUrl/certifications/$certificationId/questions',
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
    required int currentQuestion,
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
        'currentQuestion': questionId,
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


  
  static Future<Map<String, dynamic>?> fetchActiveExam() async {
    final token = await AuthStorage.getToken();
    final res = await http.get(
    Uri.parse('$baseUrl/exams/active'),
    headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200 && res.body != 'null') {
      return jsonDecode(res.body);
    }
    return null;
  }


  static Future<List<ExamAttempt>> fetchExamHistory() async {
    final token = await AuthStorage.getToken();
    final res = await http.get(
    Uri.parse('$baseUrl/exams/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => ExamAttempt.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load history');
    }
}




}
