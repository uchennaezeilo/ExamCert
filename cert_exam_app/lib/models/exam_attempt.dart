class ExamAttempt {
  final int id;
  final String certificationName;
  final int? score;
  final DateTime startedAt;
  final DateTime? finishedAt;

  ExamAttempt({
    required this.id,
    required this.certificationName,
    this.score,
    required this.startedAt,
    this.finishedAt,
  });

  bool get isFinished => finishedAt != null;

  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      id: json['id'],
      certificationName: json['name'],
      score: json['score'],
      startedAt: DateTime.parse(json['started_at']),
      finishedAt:
          json['finished_at'] != null ? DateTime.parse(json['finished_at']) : null,
    );
  }
}
