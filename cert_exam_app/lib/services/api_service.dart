import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/certification.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<dynamic>> fetchQuestionsByCertification(int certificationId) async {
  final url = Uri.parse(
    'http://localhost:3000/certifications/$certificationId/questions',
  );

  print('➡️ REQUEST URL: $url');
  print('➡️ certificationId: $certificationId');

  final response = await http.get(url);

  print('⬅️ RESPONSE STATUS: ${response.statusCode}');
  print('⬅️ RESPONSE BODY: ${response.body}');

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
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
