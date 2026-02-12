import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/question.dart';

class ExamReviewScreen extends StatefulWidget {
  final int attemptId;
  const ExamReviewScreen({super.key, required this.attemptId});

  @override
  State<ExamReviewScreen> createState() => _ExamReviewScreenState();
}

class _ExamReviewScreenState extends State<ExamReviewScreen> {
  late Future<List<dynamic>> _reviewFuture;

  @override
  void initState() {
    super.initState();
    _reviewFuture = ApiService.fetchExamReview(widget.attemptId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Review')),
      body: FutureBuilder<List<dynamic>>(
        future: _reviewFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final q = Question.fromMap(item);
              final selectedOption = item['selected_option'];
              final correctOption = item['correct_option'] ?? item['correctOption']; // Handle DB variations

              // Convert numeric correctOption to letter if necessary (depends on DB storage)
              String correctLetter = correctOption.toString();
              if (int.tryParse(correctLetter) != null) {
                 const letters = ['A','B','C','D','E'];
                 int idx = int.parse(correctLetter);
                 if (idx >= 0 && idx < letters.length) correctLetter = letters[idx];
              }

              final isCorrect = selectedOption == correctLetter;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: isCorrect ? Colors.green : Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${index + 1}: ${q.question}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildOptionRow('A', q.optionA, selectedOption, correctLetter),
                      _buildOptionRow('B', q.optionB, selectedOption, correctLetter),
                      _buildOptionRow('C', q.optionC, selectedOption, correctLetter),
                      _buildOptionRow('D', q.optionD, selectedOption, correctLetter),
                      if (q.optionE.isNotEmpty)
                        _buildOptionRow('E', q.optionE, selectedOption, correctLetter),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOptionRow(String letter, String text, String? selected, String correct) {
    if (text.isEmpty) return const SizedBox.shrink();

    Color? bgColor;
    Color textColor = Colors.black;
    IconData? icon;

    if (letter == correct) {
      bgColor = Colors.green.shade100;
      icon = Icons.check_circle;
      textColor = Colors.green.shade900;
    } else if (letter == selected && letter != correct) {
      bgColor = Colors.red.shade100;
      icon = Icons.cancel;
      textColor = Colors.red.shade900;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text('$letter. ', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          Expanded(child: Text(text, style: TextStyle(color: textColor))),
          if (icon != null) Icon(icon, size: 16, color: textColor),
        ],
      ),
    );
  }
}