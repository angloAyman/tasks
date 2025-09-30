

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks/features/tasks/data/datasource/NotificationService.dart';
import 'package:tasks/features/tasks/domain/entities/message_entity.dart';
import 'task_chat_state.dart';

class TaskChatCubit extends Cubit<TaskChatState> {
  final SupabaseClient supabase;
  RealtimeChannel? _channel;
  final List<MessageEntity> _messages = [];

  TaskChatCubit(this.supabase) : super(TaskChatInitial());

  Future<void> subscribeToMessages(String taskId) async {
    try {
      _channel = supabase.channel('task_chats_$taskId');

      _channel!
          .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'task_chats',
        ),
            (payload, [ref]) async {
          final newRecord = (payload['new'] ?? payload['record']);
          if (newRecord != null && newRecord['task_id'] == taskId) {


            // merge newRecord with profile
            final mergedRecord = {
              ...Map<String, dynamic>.from(newRecord),
            };

            final message = MessageEntity.fromMap(mergedRecord);
            _messages.add(message);
            emit(TaskChatLoaded(List.from(_messages)));

            // 👇 Check: لو المرسل هو أنا، لا تبعت إشعار
            final currentUserId = supabase.auth.currentUser?.id;
            final senderId = newRecord['sender_id'];


            // 🔔 إرسال إشعار عند استقبال رسالة جديدة
            if (senderId != currentUserId) {
              final senderName = newRecord['senderName'] ?? 'Someone';
              final content = newRecord['content'] ?? '';
              final fileUrl = newRecord['file_url'];

            await NotificationService.showNotification(
              title: "New message from $senderName",
              body: fileUrl != null && fileUrl.isNotEmpty
                  ? "📎 Sent a file"
                  : (content.isNotEmpty ? content : "New message"),
            );
          }
            }}
      ).subscribe();

      await loadMessages(taskId);
      print("subscribeToMessages in task_chat_cubit done ");
    } catch (e) {
      emit(TaskChatError(e.toString()));
    }
  }

  /// تحميل الرسائل القديمة
  Future<void> loadMessages(String taskId) async {
    emit(TaskChatLoading());
    try {
      final response = await supabase
          .from('task_chats')
          .select('*') // Fixed: Use proper join syntax
          .eq('task_id', taskId)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((m) => MessageEntity.fromMap(m))
          .toList();

      _messages
        ..clear()
        ..addAll(messages);

      emit(TaskChatLoaded(List.from(_messages)));
      print("loadMessages in task_chat_cubit done ");

    } catch (e) {
      // Add error details for debugging
      print("Error loading messages: $e");
      emit(TaskChatError(e.toString()));
    }
  }

  /// إرسال رسالة جديدة
  Future<void> sendMessage({
    required String taskId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      await supabase.from('task_chats').insert({
        'task_id': taskId,
        'sender_id': senderId,
        'senderName': senderName,
        'content': content,
      });
      // No need to call loadMessages here as realtime will handle it
      print("sendMessage in task_chat_cubit done ");

    } catch (e) {
      emit(TaskChatError(e.toString()));
    }
  }

  Future<void> sendFileMessage({
    required String taskId,
    required String senderId,
    required String senderName,
    required File file,
  }) async {
    try {
      final ext = file.path.split('.').last;
      final fileType = _detectFileType(ext);

      final fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";

      // Upload file to Supabase Storage
      await supabase.storage
          .from('chat_files') // 👈 your bucket
          .upload('task_$taskId/$fileName', file);

      // Get public URL
      final publicUrl = supabase.storage
          .from('chat_files')
          .getPublicUrl('task_$taskId/$fileName');

      // Insert into task_chats table
      await supabase.from('task_chats').insert({
        'task_id': taskId,
        'sender_id': senderId,
        'senderName': senderName, // 👈 must match MessageEntity
        'content': '',
        'file_url': publicUrl,
        'file_type': fileType,
      });

      print("sendFileMessage in task_chat_cubit done ");
    } catch (e) {
      print("Error sending file: $e");
      emit(TaskChatError(e.toString()));
    }
  }


  String _detectFileType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'image';
      case 'mp4':
      case 'mov':
      case 'avi':
        return 'video';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'word';
      default:
        return 'file';
    }
  }



  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}