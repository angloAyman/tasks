import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> fetchTasks({String? teamId});
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
}
