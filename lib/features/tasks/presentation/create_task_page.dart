//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tasks/features/tasks/domain/entities/task_entity.dart';
// import 'package:tasks/features/tasks/presentation/cubit/tasks_cubit.dart';
// import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
// import 'package:tasks/features/teams/presentation/cubit/teams_cubit.dart';
// import 'package:uuid/uuid.dart';
//
// import '../../teams/presentation/cubit/ProfilesCubit.dart';
//
// class CreateTaskPage extends StatefulWidget {
//   const CreateTaskPage({super.key});
//
//   @override
//   State<CreateTaskPage> createState() => _CreateTaskPageState();
// }
//
// class _CreateTaskPageState extends State<CreateTaskPage> {
//   final _title = TextEditingController();
//   final _desc = TextEditingController();
//   final _dueDate = TextEditingController();
//
//   DateTime? _selectedDate;
//
//   String _assigneeType = "team"; // default
//   List<String> _selectedAssigneenames = []; // ✅ multiple assignees
//
//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: now,
//       firstDate: now,
//       lastDate: DateTime(now.year + 5),
//     );
//
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _dueDate.text = "${picked.toLocal()}".split(' ')[0];
//       });
//     }
//   }
//
//   void _save() {
//     final authState = context.read<AuthCubit>().state;
//     String? userId;
//
//     if (authState is AuthSuccess) {
//       userId = authState.user.id;
//     }
//
//     final task = TaskEntity(
//       id: const Uuid().v4(),
//       title: _title.text,
//       description: _desc.text,
//       status: 'pending',
//       priority: 1,
//       dueDate: _selectedDate,
//       createdBy: userId,
//       assignee_names: _selectedAssigneenames, // ✅ list instead of one
//       teamId: _assigneeType == "team" ? null : null, // optional
//       assigneeType: _assigneeType, // ✅ store type directly
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
//
//     context.read<TasksCubit>().addTask(task);
//     Navigator.of(context).pop();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<TeamsCubit>().loadTeams();
//     context.read<ProfilesCubit>().loadProfiles();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Task')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: _title,
//                 decoration: const InputDecoration(labelText: 'Title'),
//               ),
//               TextField(
//                 controller: _desc,
//                 decoration: const InputDecoration(labelText: 'Description'),
//               ),
//               TextField(
//                 controller: _dueDate,
//                 decoration: const InputDecoration(labelText: 'Due Date'),
//                 readOnly: true,
//                 onTap: _pickDate,
//               ),
//               const SizedBox(height: 20),
//
//               /// Step 1: Choose type
//               DropdownButtonFormField<String>(
//                 value: _assigneeType,
//                 items: const [
//                   DropdownMenuItem(value: "team", child: Text("Assign to Teams")),
//                   DropdownMenuItem(value: "member", child: Text("Assign to Members")),
//                 ],
//                 onChanged: (val) {
//                   setState(() {
//                     _assigneeType = val!;
//                     _selectedAssigneenames = []; // ✅ reset list properly
//                   });
//                 },
//                 decoration: const InputDecoration(labelText: "Assignee Type"),
//               ),
//               const SizedBox(height: 10),
//
//               /// Step 2: Multi-select assignees
//               if (_assigneeType == "team")
//                 BlocBuilder<TeamsCubit, List<dynamic>>(
//                   builder: (context, teams) {
//                     if (teams.isEmpty) return const Text("No teams available");
//                     return ExpansionTile(
//                       title: const Text("Select Teams"),
//                       children: teams.map((team) {
//                         final isSelected = _selectedAssigneenames.contains(team.name);
//                         return CheckboxListTile(
//                           title: Text(team.name),
//                           value: isSelected,
//                           onChanged: (val) {
//                             setState(() {
//                               if (val == true) {
//                                 _selectedAssigneenames.add(team.name);
//                               } else {
//                                 _selectedAssigneenames.remove(team.name);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     );
//                   },
//                 )
//               else
//                 BlocBuilder<ProfilesCubit, List<Map<String, dynamic>>>(
//                   builder: (context, profiles) {
//                     if (profiles.isEmpty) return const Text("No members available");
//                     return ExpansionTile(
//                       title: const Text("Select Members"),
//                       children: profiles.map((user) {
//                         final isSelected = _selectedAssigneenames.contains(user['username']);
//                         return CheckboxListTile(
//                           title: Text("${user['username']} (${user['email']})"),
//                           value: isSelected,
//                           onChanged: (val) {
//                             setState(() {
//                               if (val == true) {
//                                 _selectedAssigneenames.add(user['username']);
//                               } else {
//                                 _selectedAssigneenames.remove(user['username']);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//
//               const SizedBox(height: 20),
//               ElevatedButton(onPressed: _save, child: const Text('Save'))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:tasks/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
import 'package:tasks/features/teams/presentation/cubit/teams_cubit.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../teams/presentation/cubit/ProfilesCubit.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dueDateController = TextEditingController();

  DateTime? _selectedDate;
  int _priority = 2; // Default to medium priority
  String _assigneeType = "team";
  List<String> _selectedAssigneeNames = [];
  bool _isSubmitting = false;

  final List<int> _priorityOptions = [1, 2, 3];
  final Map<int, String> _priorityLabels = {
    1: 'High 🔴',
    2: 'Medium 🟡',
    3: 'Low 🟢'
  };

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authState = context.read<AuthCubit>().state;
    String? userId;

    if (authState is AuthSuccess) {
      userId = authState.user.id;
    }

    final task = TaskEntity(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: 'pending',
      priority: _priority,
      dueDate: _selectedDate,
      createdBy: userId,
      assignee_names: _selectedAssigneeNames,
      teamId: _assigneeType == "team" ? null : null,
      assigneeType: _assigneeType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await context.read<TasksCubit>().addTask(task);
      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descController.clear();
    _dueDateController.clear();
    setState(() {
      _selectedDate = null;
      _priority = 2;
      _selectedAssigneeNames.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<TeamsCubit>().loadTeams();
    context.read<ProfilesCubit>().loadProfiles();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Clear form',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
        
                  // Description Field
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
        
                  // Due Date Field
                  TextFormField(
                    controller: _dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                            _dueDateController.clear();
                          });
                        },
                      ),
                    ),
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),
        
                  // Priority Selection
                  DropdownButtonFormField<int>(
                    value: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    items: _priorityOptions.map((priority) {
                      return DropdownMenuItem<int>(
                        value: priority,
                        child: Text(_priorityLabels[priority]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _priority = value!);
                    },
                    validator: (value) {
                      if (value == null) return 'Please select a priority';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
        
                  // Assignee Type Selection
                  DropdownButtonFormField<String>(
                    value: _assigneeType,
                    decoration: const InputDecoration(
                      labelText: 'Assignee Type *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.group),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "team",
                        child: Text("Assign to Teams"),
                      ),
                      DropdownMenuItem(
                        value: "member",
                        child: Text("Assign to Members"),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _assigneeType = val!;
                        _selectedAssigneeNames.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
        
                  // Selected Assignees Display
                  if (_selectedAssigneeNames.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: _selectedAssigneeNames.map((name) {
                        return Chip(
                          label: Text(name),
                          onDeleted: () {
                            setState(() => _selectedAssigneeNames.remove(name));
                          },
                          deleteIcon: const Icon(Icons.close, size: 16),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
        
                  // Assignee Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _assigneeType == "team"
                                ? "Select Teams"
                                : "Select Members",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _assigneeType == "team"
                              ? BlocBuilder<TeamsCubit, List<dynamic>>(
                            builder: (context, teams) {
                              if (teams.isEmpty) {
                                return const ListTile(
                                  leading: Icon(Icons.info),
                                  title: Text("No teams available"),
                                );
                              }
                              return Column(
                                children: teams.map((team) {
                                  final isSelected = _selectedAssigneeNames.contains(team.name);
                                  return CheckboxListTile(
                                    title: Text(team.name),
                                    subtitle: team.description != null
                                        ? Text(team.description!)
                                        : null,
                                    value: isSelected,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedAssigneeNames.add(team.name);
                                        } else {
                                          _selectedAssigneeNames.remove(team.name);
                                        }
                                      });
                                    },
                                    secondary: const Icon(Icons.group),
                                  );
                                }).toList(),
                              );
                            },
                          )
                              : BlocBuilder<ProfilesCubit, List<Map<String, dynamic>>>(
                            builder: (context, profiles) {
                              if (profiles.isEmpty) {
                                return const ListTile(
                                  leading: Icon(Icons.info),
                                  title: Text("No members available"),
                                );
                              }
                              return Column(
                                children: profiles.map((user) {
                                  final isSelected = _selectedAssigneeNames.contains(user['username']);
                                  return CheckboxListTile(
                                    title: Text(user['username'] ?? 'Unknown'),
                                    subtitle: Text(user['email'] ?? ''),
                                    value: isSelected,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedAssigneeNames.add(user['username']);
                                        } else {
                                          _selectedAssigneeNames.remove(user['username']);
                                        }
                                      });
                                    },
                                    secondary: const Icon(Icons.person),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
        
                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Text(
                      'Create Task',
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ),
        
                  // Cancel Button
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}