import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  const TeamEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name,description, createdAt];
}
