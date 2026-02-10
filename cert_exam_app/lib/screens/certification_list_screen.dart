import 'package:flutter/material.dart';
import '../models/certification.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import 'quiz_screen.dart';

class CertificationListScreen extends StatelessWidget {
  const CertificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Certification')),
      body: FutureBuilder<List<Certification>>(
        future: ApiService.fetchCertifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final certs = snapshot.data ?? [];
          if (certs.isEmpty) {
            return const Center(child: Text('No certifications available.'));
          }
          return ListView.builder(
            itemCount: certs.length,
            itemBuilder: (context, index) {
              final cert = certs[index];
              return ListTile(
                title: Text(cert.name),
                subtitle: Text(cert.description),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  final token = await AuthStorage.getToken();
                  if (token != null && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(certificationId: cert.id, token: token),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}