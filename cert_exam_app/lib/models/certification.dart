// models/certification.dart
class Certification {
  final int id;
  final String name;

  Certification({required this.id, required this.name});

  factory Certification.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    final dynamic rawName = json['name'];

    if (rawId == null) {
      throw FormatException('Certification missing `id`: $json');
    }

    final int id = rawId is int
        ? rawId
        : int.tryParse(rawId.toString()) ?? (throw FormatException('Invalid certification id: $rawId'));

    final String name = rawName?.toString() ?? 'Unnamed Certification';

    return Certification(id: id, name: name);
  }
}
