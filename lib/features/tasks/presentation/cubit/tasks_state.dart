part of 'tasks_cubit.dart';

abstract class TasksState extends Equatable {
  @override
  List<Object?> get props => [];
}
class TasksInitial extends TasksState {}
class TasksLoading extends TasksState {}
class TasksLoaded extends TasksState {
  final List<TaskEntity> tasks;
  TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}
class TasksError extends TasksState {
  final String message;
  TasksError(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskAdded extends TasksState {}
class TaskUpdated extends TasksState {}
class TaskDeleted extends TasksState {}
