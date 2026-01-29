import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final int certificationId;
  const QuizScreen({super.key, required this.certificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz for Certification $certificationId')),
      body: const Center(child: Text('Quiz Questions will appear here.')),
    );
  }
}
