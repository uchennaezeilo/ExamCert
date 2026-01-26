import 'package:flutter/material.dart';
import '../db/db_helper.dart';

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
  int _correctIndex = 0;
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

  void _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      await DBHelper.instance.insertQuestion({
        'question': _questionController.text.trim(),
        'optionA': _optionControllers[0].text.trim(),
        'optionB': _optionControllers[1].text.trim(),
        'optionC': _optionControllers[2].text.trim(),
        'optionD': _optionControllers[3].text.trim(),
        'optionE': _optionControllers[4].text.trim(),
        'correctIndex': _correctIndex,
        'difficulty': _difficulty,
        'certificationId': _certificationId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question saved!')),
      );

      _questionController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
      setState(() {
        _correctIndex = 0;
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
                validator: (value) => value!.isEmpty ? 'Enter question' : null,
              ),
              const SizedBox(height: 16),
              ...List.generate(5, (i) {
                return TextFormField(
                  controller: _optionControllers[i],
                  decoration: InputDecoration(labelText: 'Option ${String.fromCharCode(65 + i)}'),
                  validator: (value) => value!.isEmpty ? 'Enter option ${String.fromCharCode(65 + i)}' : null,
                );
              }),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _correctIndex,
                items: List.generate(5, (i) => DropdownMenuItem(
                  value: i,
                  child: Text('Correct: Option ${String.fromCharCode(65 + i)}'),
                )),
                onChanged: (val) => setState(() => _correctIndex = val!),
                decoration: const InputDecoration(labelText: 'Correct Answer'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _difficulty,
                items: _difficultyLevels.map((level) => DropdownMenuItem(
                  value: level,
                  child: Text('Difficulty: $level'),
                )).toList(),
                onChanged: (val) => setState(() => _difficulty = val!),
                decoration: const InputDecoration(labelText: 'Difficulty'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: '1',
                decoration: const InputDecoration(labelText: 'Certification ID'),
                onChanged: (val) => setState(() => _certificationId = int.tryParse(val) ?? 1),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveQuestion,
                child: const Text('Save Question'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
