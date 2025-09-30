
import 'package:tasks/features/tasks/domain/entities/message_entity.dart';

abstract class TaskChatState {}

class TaskChatInitial extends TaskChatState {}

class TaskChatLoading extends TaskChatState {}

class TaskChatLoaded extends TaskChatState {
  final List<MessageEntity> messages;
  TaskChatLoaded(this.messages);
}

class TaskChatError extends TaskChatState {
  final String message;
  TaskChatError(this.message);
}
