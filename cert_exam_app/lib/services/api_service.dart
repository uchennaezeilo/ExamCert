import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/certification.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Map<String, dynamic>>> fetchQuestions({int? certificationId}) async {
    final uri = certificationId != null
        ? Uri.parse('$baseUrl/questions?certificationId=$certificationId')
        : Uri.parse('$baseUrl/questions');

    final res = await http.get(uri);

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
