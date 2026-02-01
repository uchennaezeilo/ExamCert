class Question {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String optionE;
  final String correctOption;

  Question({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.optionE,
    required this.correctOption,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    // Accept multiple possible key names coming from different sources (DB, local JSON)
    String _toStr(dynamic v) => v == null ? '' : v.toString();

    final optionA = _toStr(map['option_a'] ?? map['optionA'] ?? '');
    final optionB = _toStr(map['option_b'] ?? map['optionB'] ?? '');
    final optionC = _toStr(map['option_c'] ?? map['optionC'] ?? '');
    final optionD = _toStr(map['option_d'] ?? map['optionD'] ?? '');
    final optionE = _toStr(map['option_e'] ?? map['optionE'] ?? '');

    dynamic rawCorrect = map['correct_option'] ?? map['correctOption'] ?? '';

    String correctOption;
    if (rawCorrect is int) {
      const letters = ['A','B','C','D','E'];
      correctOption = (rawCorrect >= 0 && rawCorrect < letters.length) ? letters[rawCorrect] : rawCorrect.toString();
    } else {
      final parsed = int.tryParse(rawCorrect?.toString() ?? '');
      if (parsed != null) {
        const letters = ['A','B','C','D','E'];
        correctOption = (parsed >= 0 && parsed < letters.length) ? letters[parsed] : parsed.toString();
      } else {
        correctOption = _toStr(rawCorrect);
      }
    }

    final idRaw = map['id'];
    final int id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '') ?? 0;

    final questionText = _toStr(map['question'] ?? map['question_text'] ?? '');

    return Question(
      id: id,
      question: questionText,
      optionA: optionA,
      optionB: optionB,
      optionC: optionC,
      optionD: optionD,
      optionE: optionE,
      correctOption: correctOption,
    );
  }
}
