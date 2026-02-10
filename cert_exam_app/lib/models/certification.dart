class Certification {
  final int id;
  final String name;
  final String description;

  Certification({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}