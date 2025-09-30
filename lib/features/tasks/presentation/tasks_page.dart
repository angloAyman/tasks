import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:tasks/features/tasks/presentation/create_task_page.dart';
import 'package:tasks/features/tasks/presentation/cubit/task_chat_cubit.dart';
import 'package:tasks/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:tasks/features/tasks/presentation/edit_task_page.dart';
import 'package:tasks/features/tasks/presentation/task_details_page.dart';
import 'package:tasks/features/teams/presentation/cubit/ProfilesCubit.dart';

class TasksPage extends StatefulWidget {
  final Map<String, dynamic> currentUser; // 👈 full user profile

  const TasksPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _priorityFilter = 'all';
  String _sortBy = 'created_at';
  bool _sortAscending = false;


  // Use debounce for search to avoid excessive filtering
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _debounce(() {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
      });
    });
  }

  Timer? _debounceTimer;
  void _debounce(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), callback);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }


  List<TaskEntity> _filterAndSortTasks(List<TaskEntity> tasks) {
    List<TaskEntity> filtered =
        tasks.where((task) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              task.title.toLowerCase().contains(_searchQuery) ||
              (task.description?.toLowerCase().contains(_searchQuery) ?? false);

          final matchesStatus =
              _statusFilter == 'all' || task.status == _statusFilter;

          final matchesPriority =
              _priorityFilter == 'all' ||
              (task.priority != null &&
                  task.priority.toString() == _priorityFilter);

          return matchesSearch && matchesStatus && matchesPriority;
        }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'priority':
          comparison = (a.priority ?? 0).compareTo(b.priority ?? 0);
          break;
        case 'due_date':
          final dateA = a.dueDate ?? DateTime(2100);
          final dateB = b.dueDate ?? DateTime(2100);
          comparison = dateA.compareTo(dateB);
          break;
        case 'created_at':
        default:
          final dateA = a.createdAt ?? DateTime(0);
          final dateB = b.createdAt ?? DateTime(0);
          comparison = dateA.compareTo(dateB);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Tasks'),
  //       backgroundColor:  Colors.blue.shade500   ,
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.filter_list),
  //           onPressed: _showFilterDialog,
  //           tooltip: 'Filter and Sort',
  //         ),
  //         IconButton(
  //           icon: const Icon(Icons.refresh),
  //           onPressed: () => context.read<TasksCubit>().loadTasks(),
  //           tooltip: 'Refresh',
  //         ),
  //       ],
  //     ),
  //     body: Column(
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(12.0),
  //           child: TextField(
  //             controller: _searchController,
  //             decoration: InputDecoration(
  //               hintText: 'Search tasks...',
  //               prefixIcon: const Icon(Icons.search),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               filled: true,
  //               fillColor: Colors.grey[100],
  //               suffixIcon:
  //                   _searchQuery.isNotEmpty
  //                       ? IconButton(
  //                         icon: const Icon(Icons.clear),
  //                         onPressed: () {
  //                           _searchController.clear();
  //                           setState(() {
  //                             _searchQuery = '';
  //                           });
  //                         },
  //                       )
  //                       : null,
  //             ),
  //           ),
  //         ),
  //
  //         Padding(
  //           padding: const EdgeInsets.fromLTRB(10,8,10,8),
  //           child: SizedBox(
  //             height: 40,
  //             child: ListView(
  //               scrollDirection: Axis.horizontal,
  //               children: [
  //                 _buildFilterChip("All", "all"),
  //                 _buildFilterChip("Pending", "pending"),
  //                 _buildFilterChip("InProgress", "in progress"),
  //                 _buildFilterChip("Completed", "completed"),
  //               ],
  //             ),
  //           ),
  //         ),
  //
  //         Expanded(
  //           child: BlocConsumer<TasksCubit, TasksState>(
  //             listener: (context, state) {
  //               if (state is TasksError) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text(state.message),
  //                     backgroundColor: Colors.red,
  //                   ),
  //                 );
  //               }
  //               if (state is TaskDeleted) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('Task deleted successfully'),
  //                     backgroundColor: Colors.green,
  //                   ),
  //                 );
  //               }
  //               if (state is TaskAdded) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('Task added successfully'),
  //                     backgroundColor: Colors.green,
  //                   ),
  //                 );
  //               }
  //               if (state is TaskUpdated) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('Task updated successfully'),
  //                     backgroundColor: Colors.green,
  //                   ),
  //                 );
  //               }
  //             },
  //             builder: (context, state) {
  //               if (state is TasksLoading) {
  //                 return const Center(child: CircularProgressIndicator());
  //               }
  //
  //               if (state is TasksLoaded) {
  //                 final filteredTasks = _filterAndSortTasks(state.tasks);
  //
  //                 if (filteredTasks.isEmpty) {
  //                   return _buildEmptyState();
  //                 }
  //
  //                 return ListView.builder(
  //                   itemCount: filteredTasks.length,
  //                   itemBuilder: (ctx, idx) {
  //                     final task = filteredTasks[idx];
  //                     return _buildTaskCard(context, task);
  //                   },
  //                 );
  //               }
  //
  //               if (state is TasksError) {
  //                 return _buildErrorState(state.message, context);
  //               }
  //
  //               return const Center(child: Text('No tasks'));
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder:
  //                 (_) => BlocProvider(
  //                   create: (_) => ProfilesCubit()..loadProfiles(),
  //                   child: const CreateTaskPage(),
  //                 ),
  //           ),
  //         ).then((_) => context.read<TasksCubit>().loadTasks());
  //       },
  //       child: const Icon(Icons.add),
  //       backgroundColor: Colors.blue[700],
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.task_alt, size: 24),
            SizedBox(width: 8),
            Text(
              'Tasks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          // Filter Button with badge indicator
          BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              final hasActiveFilters = _statusFilter != 'all' ||
                  _priorityFilter != 'all' ||
                  _sortBy != 'created_at' ||
                  !_sortAscending;

              return Badge(
                isLabelVisible: hasActiveFilters,
                backgroundColor: Colors.orange,
                smallSize: 8,
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                  tooltip: 'Filter and Sort',
                ),
              );
            },
          ),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TasksCubit>().loadTasks();
              // Show refresh indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Refreshing tasks...'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.blue.shade700,
                ),
              );
            },
            tooltip: 'Refresh',
          ),

          // User Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'stats',
                child: const ListTile(
                  leading: Icon(Icons.analytics, color: Colors.blue),
                  title: Text('View Statistics'),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: const ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout'),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'stats':
                  _showStatistics(context);
                  break;
                case 'settings':
                  _showSettings(context);
                  break;
                case 'logout':
                  _logout(context);
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 12),

                // Filter Chips
                SizedBox(
                  height: 40,
                  child: BlocBuilder<TasksCubit, TasksState>(
                    builder: (context, state) {
                      if (state is TasksLoaded) {
                        return _buildFilterChips(state.tasks);
                      }
                      return _buildFilterChips([]);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade50,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: BlocConsumer<TasksCubit, TasksState>(
                listener: (context, state) {
                  if (state is TasksError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  if (state is TaskDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task deleted successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  if (state is TaskAdded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task added successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  if (state is TaskUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task updated successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TasksLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading tasks...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TasksLoaded) {
                    final filteredTasks = _filterAndSortTasks(state.tasks);

                    if (filteredTasks.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TasksCubit>().loadTasks();
                      },
                      child: ListView.separated(
                        itemCount: filteredTasks.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        itemBuilder: (ctx, idx) {
                          final task = filteredTasks[idx];
                          return _buildTaskCard(context, task);
                        },
                      ),
                    );
                  }

                  if (state is TasksError) {
                    return _buildErrorState(state.message, context);
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => ProfilesCubit()..loadProfiles(),
                child: const CreateTaskPage(),
              ),
            ),
          ).then((_) => context.read<TasksCubit>().loadTasks());
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade500,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade700.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<TaskEntity> tasks) {
    final statusCounts = {
      'all': tasks.length,
      'pending': tasks.where((t) => t.status == 'pending').length,
      'in progress': tasks.where((t) => t.status == 'in progress').length,
      'completed': tasks.where((t) => t.status == 'completed').length,
    };

    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _buildFilterChipWithCount("All", "all", statusCounts['all']!),
        _buildFilterChipWithCount("Pending", "pending", statusCounts['pending']!),
        _buildFilterChipWithCount("In Progress", "in progress", statusCounts['in progress']!),
        _buildFilterChipWithCount("Completed", "completed", statusCounts['completed']!),
      ],
    );
  }

  Widget _buildFilterChipWithCount(String label, String value, int count) {
    final isSelected = _statusFilter == value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _statusFilter = value;
          });
        },
        selectedColor: Colors.blue.shade700,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.grey.shade200,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task Statistics'),
        content: const Text('Statistics feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout functionality to be implemented'),
                ),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

// Make filter chips more accessible
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _statusFilter = value),
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }


  Widget _buildTaskCard(BuildContext context, TaskEntity task) {
    Color statusColor;
    String statusLabel;

    switch (task.status) {
      case 'completed':
        statusColor = Colors.teal;
        statusLabel = "Completed";
        break;
      case 'in progress':
        statusColor = Colors.blue;
        statusLabel = "InProgress";
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusLabel = "Pending";
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // 👉 Navigate to details page or open bottom sheet
        _showTaskDetails(context, task);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left colored strip
            Container(
              width: 6,
              height: 110,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.description?.isNotEmpty == true
                                    ? task.description!
                                    : "For Zoho Project",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.blue),
                                  const SizedBox(width: 6),
                                  Text(
                                    task.dueDate != null
                                        ? _formatDate(task.dueDate!)
                                        : "No due date",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              if (task.assignee_names != null &&
                                  task.assignee_names!.isNotEmpty)
                                Text(
                                  'Assigned to: ${task.assignee_names!.join(", ")}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                )
                              else
                                const Text(
                                  'Unassigned',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),

                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                                if (task.status != 'completed')
                                  const PopupMenuItem(
                                    value: 'complete',
                                    child: Text('Mark as Complete'),
                                  ),
                                if (task.status == 'completed')
                                  const PopupMenuItem(
                                    value: 'reopen',
                                    child: Text('Reopen Task'),
                                  ),
                              ],
                              onSelected: (v) {
                                if (v == 'delete') {
                                  _showDeleteConfirmation(context, task.id);
                                } else if (v == 'edit') {
                                  _navigateToEditTask(context, task);
                                } else if (v == 'complete') {
                                  context.read<TasksCubit>().updateTaskStatus(
                                    task.id,
                                    'completed',
                                  );
                                } else if (v == 'reopen') {
                                  context.read<TasksCubit>().updateTaskStatus(
                                    task.id,
                                    'pending',
                                  );
                                }
                              },
                            ),


                          ],
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Filter & Sort Tasks'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const SizedBox(height: 16),
                        const Text(
                          'Filter by Priority:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButtonFormField<String>(
                          value: _priorityFilter,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Priorities'),
                            ),
                            DropdownMenuItem(
                              value: '1',
                              child: Text('High (P1)'),
                            ),
                            DropdownMenuItem(
                              value: '2',
                              child: Text('Medium (P2)'),
                            ),
                            DropdownMenuItem(
                              value: '3',
                              child: Text('Low (P3)'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _priorityFilter = value ?? 'all';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sort by:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButtonFormField<String>(
                          value: _sortBy,
                          items: const [
                            DropdownMenuItem(
                              value: 'created_at',
                              child: Text('Creation Date'),
                            ),
                            DropdownMenuItem(
                              value: 'title',
                              child: Text('Title'),
                            ),
                            DropdownMenuItem(
                              value: 'status',
                              child: Text('Status'),
                            ),
                            DropdownMenuItem(
                              value: 'priority',
                              child: Text('Priority'),
                            ),
                            DropdownMenuItem(
                              value: 'due_date',
                              child: Text('Due Date'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _sortBy = value ?? 'created_at';
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Ascending Order'),
                          value: _sortAscending,
                          onChanged: (value) {
                            setState(() {
                              _sortAscending = value ?? true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _statusFilter = 'all';
                          _priorityFilter = 'all';
                          _sortBy = 'created_at';
                          _sortAscending = false;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<TasksCubit>().loadTasks();
                        setState(() {});
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.task, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No tasks found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          if (_searchQuery.isNotEmpty ||
              _statusFilter != 'all' ||
              _priorityFilter != 'all')
            const Text(
              'Try adjusting your filters or search',
              style: TextStyle(color: Colors.grey),
            )
          else
            const Text(
              'Tap the + button to create one',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }



  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Something went wrong', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TasksCubit>().loadTasks(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Color _getStatusColor(String status) {
  //   switch (status) {
  //     case 'completed':
  //       return Colors.green.shade100;
  //     case 'in progress':
  //       return Colors.blue.shade100;
  //     case 'pending':
  //       return Colors.orange.shade100;
  //     default:
  //       return Colors.grey.shade100;
  //   }
  // }
  //
  // Color _getPriorityColor(int priority) {
  //   switch (priority) {
  //     case 1:
  //       return Colors.red.shade100;
  //     case 2:
  //       return Colors.orange.shade100;
  //     case 3:
  //       return Colors.yellow.shade100;
  //     default:
  //       return Colors.grey.shade100;
  //   }
  // }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    String taskId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      context.read<TasksCubit>().deleteTask(taskId);
      return true;
    }
    return false;
  }

  void _navigateToEditTask(BuildContext context, TaskEntity task) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => EditTaskPage(task: task)))
        .then((_) => context.read<TasksCubit>().loadTasks());
  }

  void _showTaskDetails(BuildContext context, TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create:
                  (_) =>
                      TaskChatCubit(Supabase.instance.client)
                        ..subscribeToMessages(task.id),
              child: TaskDetailsPage(
                task: task,
                currentUser:
                    widget.currentUser!, // 👈 pass the full user profile
              ),
            ),
      ),
    );
  }
}
