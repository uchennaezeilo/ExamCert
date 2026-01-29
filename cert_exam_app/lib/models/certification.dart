// models/certification.dart
class Certification {
  final int id;
  final String name;

  Certification({required this.id, required this.name});

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'],
      name: json['name'],
    );
  }
}
