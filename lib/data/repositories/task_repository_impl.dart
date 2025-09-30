//
// import 'package:tasks/features/tasks/domain/entities/task_entity.dart';
// import 'package:tasks/features/tasks/domain/repositories/task_repository.dart';
//
// import '../datasources/supabase_service.dart';
// import '../models/task_model.dart';
//
// class TaskRepositoryImpl implements TaskRepository {
//   final SupabaseService service;
//   TaskRepositoryImpl(this.service);
//
//   @override
//   Future<void> createTask(TaskEntity task) async {
//     final model = TaskModel(
//       id: task.id,
//       title: task.title,
//       description: task.description,
//       status: task.status,
//       priority: task.priority,
//       dueDate: task.dueDate,
//       createdBy: task.createdBy,
//       assigneeIds: task.assigneeIds, // ✅ support list
//       teamId: task.teamId,
//       createdAt: task.createdAt,
//     );
//     await service.createTask(model.toMap());
//   }
//
//   @override
//   Future<void> deleteTask(String id) async {
//     await service.deleteTask(id);
//   }
//
//   @override
//   Future<List<TaskEntity>> fetchTasks({String? teamId}) async {
//     final result = await service.fetchTasks(teamId: teamId);
//     return result.map((m) => TaskModel.fromMap(m).toEntity()).toList();
//   }
//
//   @override
//   Future<void> updateTask(TaskEntity task) async {
//     final model = TaskModel(
//       id: task.id,
//       title: task.title,
//       description: task.description,
//       status: task.status,
//       priority: task.priority,
//       dueDate: task.dueDate,
//       createdBy: task.createdBy,
//       assigneeIds: task.assigneeIds, // ✅ support list
//       teamId: task.teamId,
//       createdAt: task.createdAt,
//     );
//     await service.updateTask(model.id, model.toMap());
//   }
// }


import 'package:tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:tasks/features/tasks/domain/repositories/task_repository.dart';
import '../datasources/supabase_service.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final SupabaseService service;
  TaskRepositoryImpl(this.service);

  @override
  Future<void> createTask(TaskEntity task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      createdBy: task.createdBy,
      assigneeType: task.assigneeType,
      assignee_names: task.assignee_names, // ✅ multiple assignees supported
      teamId: task.teamId,
      createdAt: task.createdAt,
    );
    await service.createTask(model.toMap());
  }

  @override
  Future<void> deleteTask(String id) async {
    await service.deleteTask(id);
  }

  @override
  Future<List<TaskEntity>> fetchTasks({String? teamId}) async {
    final result = await service.fetchTasks(teamId: teamId);
    return result.map((m) => TaskModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      createdBy: task.createdBy,
      assigneeType: task.assigneeType,
      assignee_names: task.assignee_names,
      teamId: task.teamId,
      createdAt: task.createdAt,
    );
    await service.updateTask(model.id, model.toMap());
  }
}
