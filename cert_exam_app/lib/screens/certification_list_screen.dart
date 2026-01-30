// lib/screens/certification_list_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/certification.dart';
import 'quiz_screen.dart'; // We'll create this next

class CertificationListScreen extends StatelessWidget {
  const CertificationListScreen({super.key});
  

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Exam')),
      body: FutureBuilder<List<Certification>>(
        future: ApiService.fetchCertifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exams available'));
          } else {
            final certifications = snapshot.data!;
            return ListView.builder(
              itemCount: certifications.length,
              itemBuilder: (context, index) {
                final cert = certifications[index];
                return ListTile(
                  title: Text(cert.name),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(certificationId: certifications[index].id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
