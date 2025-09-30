import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:tasks/features/tasks/domain/repositories/task_repository.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TaskRepository repository;
  TasksCubit(this.repository) : super(TasksInitial());

  Future<void> loadTasks() async {
    emit(TasksLoading());
    try {
      final tasks = await repository.fetchTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  /// Load only tasks assigned to a specific member
  Future<void> loadMemberTasks(String memberId) async {
    emit(TasksLoading());
    try {
      final tasks = await repository.fetchTasks();
      final memberTasks = tasks.where((t) {
        // check if assigneeType is member and assigneeIds contains this member
        if (t.assigneeType == 'member' && t.assignee_names != null) {
          return t.assignee_names!.contains(memberId);
        }
        return false;
      }).toList();
      emit(TasksLoaded(memberTasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> addTask(TaskEntity task) async {
    try {
      await repository.createTask(task);
      emit(TaskAdded()); // ⬅️ إشعار أن التاسك اتضاف
      await loadTasks();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    try {
      await repository.updateTask(task);
      emit(TaskUpdated()); // ⬅️ إشعار أن التاسك اتعدل

      await loadTasks();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await repository.deleteTask(id);
      emit(TaskDeleted()); // ⬅️ إشعار أن التاسك اتمسح
      await loadTasks();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> updateTaskStatus(String id, String status) async {
    try {
      // هنا تجيب التاسك الحالي
      final tasks = state is TasksLoaded ? (state as TasksLoaded).tasks : [];
      final task = tasks.firstWhere((t) => t.id == id);

      // تبني نسخة جديدة بالتحديث
      final updatedTask = task.copyWith(status: status);

      await repository.updateTask(updatedTask);
      emit(TaskUpdated());
      await loadTasks();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }


}
