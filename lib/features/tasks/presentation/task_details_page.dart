import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'package:tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:tasks/features/tasks/presentation/edit_task_page.dart';
import 'package:tasks/features/tasks/presentation/cubit/task_chat_cubit.dart';
import 'package:tasks/features/tasks/presentation/cubit/task_chat_state.dart';
import 'package:tasks/features/tasks/domain/entities/message_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskEntity task;
  final Map<String, dynamic> currentUser; // 👈 full user profile

  const TaskDetailsPage({Key? key,
    required this.task,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isChatExpanded = true;

  String formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      // Same day → show only time
      return DateFormat('HH:mm').format(date);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return "Yesterday ${DateFormat('HH:mm').format(date)}";
    } else if (date.year == now.year) {
      // Same year → show day & month
      return DateFormat('dd MMM HH:mm').format(date); // e.g. 16 Sep 14:25
    } else {
      // Different year → show full date
      return DateFormat('dd MMM yyyy HH:mm').format(date); // e.g. 16 Sep 2024 14:25
    }
  }

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? "";
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) {
        final cubit = TaskChatCubit(Supabase.instance.client);
        cubit.subscribeToMessages(widget.task.id);
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Task',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditTaskPage(task: widget.task),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Task details section
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildTaskInfo(widget.task),
              ),
            ),

            const Divider(height: 1),

            // Chat section
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  // Chat header
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: const Text(
                      "Task Chat",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _isChatExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      onPressed: () {
                        setState(() {
                          _isChatExpanded = !_isChatExpanded;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _isChatExpanded = !_isChatExpanded;
                      });
                    },
                  ),

                  // Chat messages
                  if (_isChatExpanded) ...[
                    const Divider(height: 1),
                    Expanded(
                      child: BlocConsumer<TaskChatCubit, TaskChatState>(
                        listener: (context, state) {
                          // Auto-scroll to bottom when new messages arrive
                          if (state is TaskChatLoaded && _scrollController.hasClients) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            });
                          }
                        },
                        builder: (context, state) {
                          if (state is TaskChatLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state is TaskChatLoaded) {
                            final messages = state.messages;

                            if (messages.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    "No messages yet. Start the conversation!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: messages.length,
                              itemBuilder: (ctx, i) {
                                final msg = messages[i];
                                final isMine = msg.senderId == currentUserId;
                                final showSender = i == 0 ||
                                    messages[i-1].senderId != msg.senderId ||
                                    messages[i-1].senderName != msg.senderName;

                                return _buildMessageBubble(msg, isMine, showSender);
                              },
                            );
                          }

                          if (state is TaskChatError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Failed to load messages",
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      state.message,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        context.read<TaskChatCubit>().subscribeToMessages(widget.task.id);
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text("Try Again"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ),

                    // Message input
                    _buildMessageInput(context, widget.task.id),

                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfo(TaskEntity task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(task.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        // const SizedBox(height: 16),
        if (task.description != null && task.description!.isNotEmpty) ...[
          const Text('Description:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(task.description!),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Chip(
              label: Text(task.status.toUpperCase(),
                  style: const TextStyle(fontSize: 12)),
              backgroundColor: _getStatusColor(task.status),
            ),
            const SizedBox(width: 8),
            if (task.priority != null)
              Chip(
                label: Text('Priority: P${task.priority}',
                    style: const TextStyle(fontSize: 12)),
                backgroundColor: _getPriorityColor(task.priority!),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (task.assignee_names != null && task.assignee_names!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Assignees:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: task.assignee_names!
                    .map((name) => Chip(label: Text(name)))
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }


  Widget _buildMessageBubble(MessageEntity msg, bool isMine, bool showSender) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMine
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMine ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMine ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSender)
                    Text(
                      isMine ? "You" : msg.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isMine ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  if (showSender) const SizedBox(height: 4),

                  // Text message (if any)
                  if (msg.content.isNotEmpty)
                    Text(
                      msg.content,
                      style: TextStyle(
                        color: isMine ? Colors.white : Colors.black,
                      ),
                    ),

                  // File preview (if any)
                  if (msg.fileUrl != null) ...[
                    const SizedBox(height: 6),
                    _buildFilePreview(msg),
                  ],

                  const SizedBox(height: 4),
                  Text(
                    formatMessageDate(msg.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(MessageEntity msg) {
    if (msg.fileType == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          msg.fileUrl!,
          width: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (msg.fileType == 'video') {
      return TextButton.icon(
        onPressed: () => launchUrl(Uri.parse(msg.fileUrl!)),
        icon: const Icon(Icons.play_circle_fill),
        label: const Text("Play Video"),
      );
    } else if (msg.fileType == 'pdf') {
      return TextButton.icon(
        onPressed: () => launchUrl(Uri.parse(msg.fileUrl!)),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("Open PDF"),
      );
    } else {
      return TextButton.icon(
        onPressed: () => launchUrl(Uri.parse(msg.fileUrl!)),
        icon: const Icon(Icons.attach_file),
        label: const Text("Download File"),
      );
    }
  }

  Widget _buildMessageInput(BuildContext context, String taskId) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? "";
    final cubit = context.read<TaskChatCubit>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  type: FileType.any,
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  context.read<TaskChatCubit>().sendFileMessage(
                    taskId: taskId,
                    senderId: currentUserId,
                    senderName: widget.currentUser['username'],
                    file: file,
                  );
                }
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty) {
                    cubit.sendMessage(
                      taskId: taskId,
                      senderId: currentUserId,
                      senderName: widget.currentUser['username'], // ✅ fixed
                      content: text,
                    );
                    _messageController.clear();
                    // Hide keyboard after sending
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade100;
      case 'in progress':
        return Colors.blue.shade100;
      case 'todo':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red.shade100;
      case 2:
        return Colors.orange.shade100;
      case 3:
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}