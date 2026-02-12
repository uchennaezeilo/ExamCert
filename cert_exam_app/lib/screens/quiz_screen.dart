import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final int certificationId;
  final String token;



  const QuizScreen({
    super.key,
    required this.certificationId,
    required this.token,
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
  bool _reviewMode = false;
  
  String? _error;

  int? _attemptId;
  late final String token;

  Timer? _timer;
  int _remainingSeconds = 1800; // 30 minutes

  @override
  void initState() {
    super.initState();
    token = widget.token;
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  // ---------------- LOAD QUESTIONS + START EXAM ----------------
  Future<void> _loadQuestions() async {
    try {
      final data =
          await ApiService.fetchQuestionsByCertification(widget.certificationId, token);

      final loaded = data
          .map((e) => Question.fromMap(e))
          .where((q) => q.question.trim().isNotEmpty)
          .toList();

      if (!mounted) return;

      _attemptId = await ApiService.startExam(
        widget.certificationId,
        token,
      );

      setState(() {
        _questions
          ..clear()
          ..addAll(loaded);
        _selectedAnswers = List<int?>.filled(_questions.length, null);
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      print('Error loading questions: $e');
      if (!mounted) return;
      
      String errorMessage = 'Failed to load questions';
      if (e.toString().contains('Status: 500')) {
        errorMessage = 'Server Error: The backend encountered a problem.';
      }

      setState(() {
        _error = errorMessage;
        _loading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _finishQuiz();
      }
    });
  }

  // ---------------- ANSWER SELECTION ----------------
  Future<void> _selectAnswer(int answerIndex) async {
    if (_quizFinished || _attemptId == null) return;

    final previousAnswer = _selectedAnswers[_currentIndex];
    final correct = _questions[_currentIndex].correctOption;

    setState(() {
      // Undo previous score
      if (previousAnswer != null &&
          _optionLetter(previousAnswer) == correct) {
        _score--;
      }

      _selectedAnswers[_currentIndex] = answerIndex;

      if (_optionLetter(answerIndex) == correct) {
        _score++;
      }
    });

    try {
      await ApiService.saveAnswer(
        attemptId: _attemptId!,
        questionId: _questions[_currentIndex].id,
        selectedOption: _optionLetter(answerIndex),
        currentQuestion: _questions[_currentIndex].id,
        token: token,
      );
    } catch (e) {
      print('Failed to save answer: $e');
      // Optionally, show a SnackBar to inform the user that the answer could not be saved.
    }
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

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    try {
      if (_attemptId != null) {
        await ApiService.finishExam(_attemptId!, token);
      }
    } catch (e) {
      print('Error finishing exam: $e');
    }
    if (mounted) setState(() => _quizFinished = true);
  }

  // ---------------- UTILS ----------------
  String _optionLetter(int index) {
    return ['A', 'B', 'C', 'D', 'E'][index];
  }
 
  String get _timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

    if (_quizFinished && !_reviewMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Quiz Completed!'),
              const SizedBox(height: 16),
              Text('Your Score: $_score / ${_questions.length}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _reviewMode = true;
                    _currentIndex = 0;
                  });
                },
                child: const Text('Review Answers'),
              ),
              const SizedBox(height: 16),
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Q ${_currentIndex + 1}/${_questions.length}'),
            if (!_reviewMode)
              Text(
                _timerText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _remainingSeconds < 60 ? Colors.red : null,
                ),
              ),
            if (_reviewMode) const Text('Review Mode', style: TextStyle(fontSize: 14)),
          ],
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
                      : (_currentIndex == _questions.length - 1 && !_reviewMode
                          ? _finishQuiz 
                          : _goToNext),
                  child: Text(_currentIndex == _questions.length - 1 
                      ? (_reviewMode ? 'Exit Review' : 'Finish') 
                      : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerButton(String text, int index) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final selected = _selectedAnswers[_currentIndex];
    final correctOption = _questions[_currentIndex].correctOption;
    final currentOptionLetter = _optionLetter(index);
    Color? background;

    if (_reviewMode) {
      if (currentOptionLetter == correctOption) {
        background = Colors.green.shade300; // Always show correct answer in green
      } else if (selected == index) {
        background = Colors.red.shade300; // Show wrong selection in red
      } else {
        background = Colors.grey.shade200;
      }
    } else if (selected != null) {
      if (index == selected) {
        background =
            currentOptionLetter == correctOption
                ? Colors.green
                : Colors.red;
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
        onPressed: _reviewMode 
            ? null 
            : () => _selectAnswer(index),
        child: Text(text),
      ),
    );
  }
}
