import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String status;       // todo, in_progress, done
  final int priority;        // 1 = low, 2 = medium, 3 = high
  final DateTime? dueDate;
  final String? createdBy;   // profile.id
  final String? assigneeId;  // profile.id
  final String? teamId;      // team.id
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.createdBy,
    this.assigneeId,
    this.teamId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    dueDate,
    createdBy,
    assigneeId,
    teamId,
    createdAt,
    updatedAt,
  ];
}
