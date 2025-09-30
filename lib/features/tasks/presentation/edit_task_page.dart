import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:tasks/features/tasks/presentation/cubit/tasks_cubit.dart';

class EditTaskPage extends StatefulWidget {
  final TaskEntity task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _dueDate;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task.title);
    _desc = TextEditingController(text: widget.task.description ?? '');
    _selectedDate = widget.task.dueDate;
    _dueDate = TextEditingController(
      text: widget.task.dueDate != null
          ? "${widget.task.dueDate!.toLocal()}".split(' ')[0]
          : '',
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dueDate.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _save() {
    final updatedTask = widget.task.copyWith(
      title: _title.text,
      description: _desc.text,
      dueDate: _selectedDate,
      updatedAt: DateTime.now(),
    );

    context.read<TasksCubit>().updateTask(updatedTask);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _dueDate,
              decoration: const InputDecoration(labelText: 'Due Date'),
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Update Task'))
          ],
        ),
      ),
    );
  }
}
