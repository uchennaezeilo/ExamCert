class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String topic;

  Question({required this.id, required this.question, required this.options, required this.correctIndex, required this.topic});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
      topic: json['topic'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'topic': topic,
  };
}

