// team_entity.dart
class TeamEntity {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  TeamEntity({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });
}
