import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final int certificationId;

  const QuizScreen({
    super.key,
    required this.certificationId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Question> _questions = [];
  late List<int?> _selectedAnswers;

  int _currentIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _quizFinished = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = [];
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data =
          await ApiService.fetchQuestionsByCertification(widget.certificationId);

      final loaded = data
          .map((e) => Question.fromMap(e))
          .where((q) => q.question.trim().isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        _questions.clear();
        _questions.addAll(loaded);
        _selectedAnswers = List<int?>.filled(_questions.length, null);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load questions';
        _loading = false;
      });
    }
  }

  // ---------------- ANSWER SELECTION ----------------
  void _selectAnswer(int answerIndex) {
  if (_quizFinished) return;

  final previousAnswer = _selectedAnswers[_currentIndex];
  final correct = _questions[_currentIndex].correctOption;

  setState(() {
    // If there was a previous answer, undo its score impact
    if (previousAnswer != null &&
        _optionLetter(previousAnswer) == correct) {
      _score--;
    }

    // Save new answer
    _selectedAnswers[_currentIndex] = answerIndex;

    // Apply new score impact
    if (_optionLetter(answerIndex) == correct) {
      _score++;
    }
  });
}


  // ---------------- NAVIGATION ----------------
  void _goToNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _finishQuiz() {
    setState(() => _quizFinished = true);
  }

  // ---------------- UTILS ----------------
  String _optionLetter(int index) {
    switch (index) {
      case 0:
        return 'A';
      case 1:
        return 'B';
      case 2:
        return 'C';
      case 3:
        return 'D';
      case 4:
        return 'E';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(child: Text(_error!)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No questions available for this certification.'),
        ),
      );
    }

    if (_quizFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz Completed!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Score: $_score / ${_questions.length}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Exams'),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final selected = _selectedAnswers[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1} of ${_questions.length}',
        ),
      ),
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
            _answerButton(q.optionE ?? '', 4),

            const SizedBox(height: 24),

            // ---------------- NAV BUTTONS ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentIndex > 0 ? _goToPrevious : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : (_currentIndex == _questions.length - 1
                          ? _finishQuiz
                          : _goToNext),
                  child: Text(
                    _currentIndex == _questions.length - 1 ? 'Finish' : 'Next',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerButton(String text, int index) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final selected = _selectedAnswers[_currentIndex];

    Color? background;
    if (selected != null) {
      if (index == selected) {
        final isCorrect =
            _questions[_currentIndex].correctOption ==
                _optionLetter(index);
        background = isCorrect ? Colors.green : Colors.red;
      } else {
        background = Colors.grey.shade300;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.black,
        ),
        onPressed: _quizFinished ? null : () => _selectAnswer(index),

        child: Text(text),
      ),
    );
  }
}
