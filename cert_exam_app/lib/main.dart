import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db/db_helper.dart';
import 'screens/add_question_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Cert Exam App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'],
        question: json['question'],
        options: List<String>.from(json['options']),
        correctIndex: json['correctIndex'],
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Question> _questions = [];
  int _current = 0;
  int _score = 0;
  bool _quizDone = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await DBHelper.instance.getQuestions();
      setState(() {_questions = data.map((e) => Question.fromMap(e)).toList();});


      print('DEBUG: Loaded ${_questions.length} questions');
    } catch (e) {
      print('ERROR: Failed to load questions: $e');
    }
  }

  void _submitAnswer(int index) {
    if (_questions[_current].correctIndex == index) {
      _score++;
    }
    if (_current + 1 < _questions.length) {
      setState(() => _current++);
    } else {
      setState(() => _quizDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty && !_quizDone) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Certification Exam Practice'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add New Question',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddQuestionScreen()),
                );
              },
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading questions...'),
            ],
          ),
        ),
      );
    }

    if (_quizDone) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Complete'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add New Question',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddQuestionScreen()),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Score: $_score / ${_questions.length}',
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() {
                  _current = 0;
                  _score = 0;
                  _quizDone = false;
                }),
                child: const Text('Restart Quiz'),
              )
            ],
          ),
        ),
      );
    }

    final question = _questions[_current];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certification Exam Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Question',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddQuestionScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_current + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(question.question, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ...List.generate(question.options.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ElevatedButton(
                  onPressed: () => _submitAnswer(i),
                  child: Text(question.options[i]),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
