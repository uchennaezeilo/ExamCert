import 'package:flutter/material.dart';
import '../models/exam_attempt.dart';
import '../services/api_service.dart';

class ExamHistoryScreen extends StatelessWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam History')),
      body: FutureBuilder<List<ExamAttempt>>(
        future: ApiService.fetchExamHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const Center(child: Text('No exam history found.'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final attempt = history[index];
              return ListTile(
                title: Text(attempt.certificationName),
                subtitle: Text('Date: ${attempt.startedAt.toLocal()}'),
                trailing: Text(
                  attempt.score != null ? 'Score: ${attempt.score}' : 'In Progress',
                  style: TextStyle(color: attempt.score != null ? Colors.green : Colors.orange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}