import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(5, (_) => TextEditingController());

  int _correctOption = 0;
  String _difficulty = 'medium';
  int _certificationId = 1;

  final List<String> _difficultyLevels = ['easy', 'medium', 'hard'];

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      "question": _questionController.text.trim(),
      "option_a": _optionControllers[0].text.trim(),
      "option_b": _optionControllers[1].text.trim(),
      "option_c": _optionControllers[2].text.trim(),
      "option_d": _optionControllers[3].text.trim(),
      "option_e": _optionControllers[4].text.trim(),
      "correct_option": _correctOption,
      "certification_id": _certificationId,
      "difficulty_level": _difficulty,
    };

    final success = await ApiService.postQuestion(payload);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Question saved!' : 'Failed to save question'),
    ));

    if (success) {
      _formKey.currentState!.reset();
      _questionController.clear();
      for (final controller in _optionControllers) {
        controller.clear();
      }
      setState(() {
        _correctOption = 0;
        _difficulty = 'medium';
        _certificationId = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a question' : null,
              ),
              const SizedBox(height: 16),
              ...List.generate(5, (i) {
                return TextFormField(
                  controller: _optionControllers[i],
                  decoration: InputDecoration(
                      labelText: 'Option ${String.fromCharCode(65 + i)}'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter option' : null,
                );
              }),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _correctOption,
                items: List.generate(
                  5,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text('Correct Answer: Option ${String.fromCharCode(65 + i)}'),
                  ),
                ),
                onChanged: (val) => setState(() => _correctOption = val!),
                decoration: const InputDecoration(labelText: 'Correct Answer'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _difficulty,
                items: _difficultyLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text('Difficulty: $level'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _difficulty = val!),
                decoration: const InputDecoration(labelText: 'Difficulty'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: '1',
                decoration:
                    const InputDecoration(labelText: 'Certification ID'),
                onChanged: (val) => _certificationId = int.tryParse(val) ?? 1,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveQuestion,
                child: const Text('Save Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
