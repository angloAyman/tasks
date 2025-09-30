import 'package:equatable/equatable.dart';
import 'package:tasks/features/tasks/domain/entities/task_entity.dart';


class TaskModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String status;
  final int priority;
  final DateTime? dueDate;
  final String? createdBy;
  final List<String>? assignee_names;
  final String assigneeType; // ✅
  final String? teamId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.createdBy,
    this.assignee_names = const [],
    required this.assigneeType, // ✅
    this.teamId,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> m) => TaskModel(
    id: m['id'] as String,
    title: m['title'] as String,
    description: m['description'] as String?,
    status: m['status'] as String? ?? 'todo',
    priority: (m['priority'] ?? 1) as int,
    dueDate: m['due_date'] != null ? DateTime.parse(m['due_date']) : null,
    createdBy: m['created_by'] as String?,
    assignee_names: (m['assignee_names'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ??
        [], // ✅ parse JSON array into List<String>    teamId: m['team_id'] as String?,
    assigneeType: m['assignee_type'] as String, // ✅ default
    createdAt: DateTime.parse(m['created_at']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'due_date': dueDate?.toIso8601String(),
    'created_by': createdBy,
    'assignee_names': assignee_names, // ✅ save list to DB
    'team_id': teamId,
    'assignee_type': assigneeType, // ✅

  };

  /// 🔑 Convert TaskModel back to domain entity
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      teamId: teamId,
      assignee_names: assignee_names, // ✅ save list to DB
      status: status,
      dueDate: dueDate,
      priority: priority,
      createdAt: createdAt,
      assigneeType: assigneeType, // ✅

    );
  }

  @override
  List<Object?> get props => [id, title, description, status, priority, dueDate, createdBy, assignee_names, teamId, createdAt,assigneeType];
}


