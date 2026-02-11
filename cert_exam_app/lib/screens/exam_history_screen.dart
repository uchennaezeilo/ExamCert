import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exam_attempt.dart';
import '../services/api_service.dart';
import 'exam_review_screen.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  late Future<List<ExamAttempt>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService.fetchExamHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam History')),
      body: FutureBuilder<List<ExamAttempt>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exams taken yet.'));
          }

          final attempts = snapshot.data!;
          return ListView.separated(
            itemCount: attempts.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final attempt = attempts[index];
              final dateStr = DateFormat.yMMMd().add_jm().format(attempt.startedAt);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: attempt.score >= 70 ? Colors.green : Colors.orange,
                  child: Text(
                    '${attempt.score}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(attempt.certificationName),
                subtitle: Text(dateStr),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ExamReviewScreen(attemptId: attempt.id)));
                },
              );
            },
          );
        },
      ),
    );
  }
}