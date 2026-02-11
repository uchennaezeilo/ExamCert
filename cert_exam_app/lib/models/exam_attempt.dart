class ExamAttempt {
  final int id;
  final String certificationName;
  final int score;
  final DateTime startedAt;
  final DateTime? finishedAt;

  ExamAttempt({
    required this.id,
    required this.certificationName,
    required this.score,
    required this.startedAt,
    this.finishedAt,
  });

  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      id: json['id'],
      certificationName: json['name'] ?? 'Unknown Exam',
      score: json['score'] ?? 0,
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'])
          : null,
    );
  }

  bool get isCompleted => finishedAt != null;
}