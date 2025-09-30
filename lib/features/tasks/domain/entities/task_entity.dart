import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String status;       // todo, in_progress, done
  final int priority;        // 1 = low, 2 = medium, 3 = high
  final DateTime? dueDate;
  final String? createdBy;   // profile.id
  final List<String>? assignee_names; // ✅ multiple assignees
  final String assigneeType; // ✅ "team" or "member"
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
    this.assignee_names,
    required this.assigneeType, // ✅
    this.teamId,
    required this.createdAt,
    this.updatedAt,
  });

  /// 🔥 دالة copyWith لتحديث أي جزء من التاسك من غير ما تعيد كتابته كله
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    int? priority,
    DateTime? dueDate,
    String? createdBy,
    String? assigneeType,
    List<String>? assignee_names,
    String? teamId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdBy: createdBy ?? this.createdBy,
      assignee_names: assignee_names ?? this.assignee_names,
      assigneeType: assigneeType ?? this.assigneeType,
      teamId: teamId ?? this.teamId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    dueDate,
    createdBy,
    assignee_names,
    assigneeType,
    teamId,
    createdAt,
    updatedAt,
  ];
}
