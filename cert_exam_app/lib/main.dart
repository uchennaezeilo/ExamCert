import 'package:flutter/material.dart';
import 'models/question.dart';
import 'services/api_service.dart';
import 'screens/certification_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certification Exam',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  CertificationListScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Question> _questions = [];
  int _current = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await ApiService.fetchQuestions();
      final loaded = data.map((e) => Question.fromMap(e)).toList();

      setState(() {
        _questions = loaded;
        _loading = false;
      });
    } catch (e) {
      print('Load error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No questions found')),
      );
    }

    final q = _questions[_current];

    return Scaffold(
      appBar: AppBar(title: const Text('Certification Practice')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(q.question, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            _btn(q.optionA, 0),
            _btn(q.optionB, 1),
            _btn(q.optionC, 2),
            _btn(q.optionD, 3),
            _btn(q.optionE, 4),
          ],
        ),
      ),
    );
  }

  Widget _btn(String text, int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          if (_current + 1 < _questions.length) {
            setState(() => _current++);
          }
        },
        child: Text(text),
      ),
    );
  }
}
