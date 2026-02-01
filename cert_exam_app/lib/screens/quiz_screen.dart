import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final int certificationId;

  const QuizScreen({super.key, required this.certificationId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _current = 0;
  bool _loading = true;
  List<int?> _selectedAnswers = [];
  int _score = 0;
  bool _quizFinished = false;


  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await ApiService.fetchQuestionsByCertification(widget.certificationId);
      final loaded = data.map((e) => Question.fromMap(e)).toList();
      
      setState(() {
        _questions = loaded;
        _selectedAnswers = List.filled(_questions.length, null);
        _loading = false;
      });
    } catch (e) {
      print('Load error: $e');
      setState(() => _loading = false);
    }
  }

  void _selectAnswer(int index) {
    if (_selectedAnswers[_current] != null) return; // Prevent reselection

    setState(() {
      _selectedAnswers[_current] = index;
      if (_questions[_current].correctOption == _getAnswerOption(index)) {
        _score++;
      }
    });
  }

  String _getAnswerOption(int index) {
    switch (index) {
      case 0: return 'A';
      case 1: return 'B';
      case 2: return 'C';
      case 3: return 'D';
      case 4: return 'E';
      default: return '';
    }
  }
  void _nextOrFinish() {
    if (_current + 1 < _questions.length) {
      setState(() => _current++);
    } else {
      setState(() => _quizFinished = true);
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
      body: Center(child: Text('No questions available')),
    );
  }

  final question = _questions[_current]; 
  

    if (_quizFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Quiz Completed!', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('Your Score: $_score / ${_questions.length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Exams'),
              )
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available for this certification.')),
      );
    }

    final q = _questions[_current];

    return Scaffold(
      appBar: AppBar(title: Text('Question ${_current + 1} of ${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(q.question, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            _answerButton(q.optionA, 0),
            _answerButton(q.optionB, 1),
            _answerButton(q.optionC, 2),
            _answerButton(q.optionD, 3),
            _answerButton(q.optionE, 4),
            const SizedBox(height: 20),
            if (_selectedAnswers[_current] != null)
              ElevatedButton(
                onPressed: _nextOrFinish,
                child: Text(_current + 1 < _questions.length ? 'Next' : 'Finish'),
              )
          ],
        ),
      ),
    );
  }

  Widget _answerButton(String text, int index) {
    final selected = _selectedAnswers[_current];

    Color? color;
    if (selected != null) {
      if (index == selected) {
        final isCorrect = _questions[_current].correctOption == _getAnswerOption(index);
        color = isCorrect ? Colors.green : Colors.red;
      } else {
        color = Colors.grey.shade300;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
        ),
        onPressed: selected == null ? () => _selectAnswer(index) : null,
        child: Text(text),
      ),
    );
  }
}
