// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
// // import 'package:tasks/features/tasks/presentation/cubit/tasks_cubit.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'domain/entities/task_entity.dart';
// //
// // class MemberTasksPage extends StatefulWidget {
// //   final String memberId; // auth_uid
// //   final String memberName;
// //
// //   const MemberTasksPage({required this.memberId, required this.memberName, super.key});
// //
// //   @override
// //   State<MemberTasksPage> createState() => _MemberTasksPageState();
// // }
// //
// // class _MemberTasksPageState extends State<MemberTasksPage> {
// //   Map<String, String> _memberTeams = {}; // team_id -> team_name
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// //       await _loadMemberTeams();
// //       context.read<TasksCubit>().loadTasks(); // load all tasks and filter locally
// //     });
// //   }
// //
// //   /// Load all teams this member belongs to
// //   Future<void> _loadMemberTeams() async {
// //     final response = await Supabase.instance.client
// //         .from('team_members')
// //         .select('team_id')
// //         .eq('user_id', widget.memberId)
// //         .execute();
// //
// //     if (response  != null && response.data != null) {
// //       final dataList = response.data as List;
// //       _memberTeams = {
// //         for (var e in dataList)
// //           e['team_id'] as String: e['teams']?['name'] as String? ?? 'Unknown Team'
// //       };
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('My Tasks (${widget.memberName})'),
// //         actions: [
// //           ElevatedButton.icon(
// //             onPressed: () => context.read<AuthCubit>().signOut(),
// //             icon: const Icon(Icons.logout),
// //             label: const Text("Logout"),
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.refresh),
// //             onPressed: () async {
// //               await _loadMemberTeams();
// //               context.read<TasksCubit>().loadTasks();
// //             },
// //           ),
// //         ],
// //       ),
// //       body: BlocConsumer<TasksCubit, TasksState>(
// //         listener: (context, state) {
// //           if (state is TasksError) {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(content: Text(state.message), backgroundColor: Colors.red),
// //             );
// //           }
// //         },
// //         builder: (context, state) {
// //           if (state is TasksLoading) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //
// //           if (state is TasksLoaded) {
// //             // filter tasks assigned to this member
// //             final memberTasks = state.tasks.where((t) {
// //               if (t.assigneeType == 'member') {
// //                 return t.assignee_names != null && t.assignee_names!.contains(widget.memberName);
// //               } else if (t.assigneeType == 'team') {
// //                 if (t.assignee_names != null && t.assignee_names!.isNotEmpty) {
// //                   return t.assignee_names!.any((teamName) => _memberTeams.keys.contains(teamName));
// //                 }
// //               }
// //               return false;
// //             }).toList();
// //
// //             if (memberTasks.isEmpty) {
// //               return const Center(child: Text('No tasks assigned to you'));
// //             }
// //
// //             return ListView.builder(
// //               itemCount: memberTasks.length,
// //               itemBuilder: (ctx, idx) {
// //                 final t = memberTasks[idx];
// //                 return Card(
// //                   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                   child: ListTile(
// //                     title: Text(
// //                       t.title,
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         decoration: t.status == 'completed'
// //                             ? TextDecoration.lineThrough
// //                             : null,
// //                       ),
// //                     ),
// //                     subtitle: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         if (t.description != null && t.description!.isNotEmpty)
// //                           Text(
// //                             t.description!,
// //                             maxLines: 1,
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         const SizedBox(height: 4),
// //                         Text('Status: ${t.status}'),
// //                         if (t.assigneeType == 'team' )
// //                           Text(
// //                             'Teams: ${t.assignee_names!.join(", ")}',
// //
// //                             // 'Teams: ${t.assignee_names!.map((name) => _memberTeams[name] ?? name).join(", ")}',
// //                           ),
// //                       ],
// //                     ),
// //                     onTap: () => _showTaskDetails(context, t),
// //                   ),
// //                 );
// //               },
// //             );
// //           }
// //
// //           if (state is TasksError) {
// //             return Center(child: Text(state.message));
// //           }
// //
// //           return const Center(child: Text('No tasks found'));
// //         },
// //       ),
// //     );
// //   }
// //
// //   void _showTaskDetails(BuildContext context, TaskEntity task) {
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         title: Text(task.title),
// //         content: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               if (task.description != null && task.description!.isNotEmpty)
// //                 Text(task.description!),
// //               const SizedBox(height: 16),
// //               Text('Status: ${task.status}'),
// //               if (task.assigneeType == 'team' && task.assignee_names != null)
// //                 Text(
// //                   'Teams: ${task.assignee_names!.map((name) => _memberTeams[name] ?? name).join(", ")}',
// //                 ),
// //             ],
// //           ),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(ctx).pop(),
// //             child: const Text('Close'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
// import 'package:tasks/features/tasks/presentation/cubit/tasks_cubit.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'domain/entities/task_entity.dart';
//
// class MemberTasksPage extends StatefulWidget {
//   final String memberId; // auth_uid
//   final String memberName;
//
//   const MemberTasksPage({required this.memberId, required this.memberName, super.key});
//
//   @override
//   State<MemberTasksPage> createState() => _MemberTasksPageState();
// }
//
// class _MemberTasksPageState extends State<MemberTasksPage> {
//   Map<String, String> _memberTeams = {}; // team_id -> team_name
//   bool _isLoadingTeams = true;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await getUserTeamNames(widget.memberId);
//       context.read<TasksCubit>().loadTasks();
//     });
//   }
//
//   Future<List<String>> getUserTeamNames(String authUid) async {
//     try {
//       // 1. Find profile.id from auth_uid
//       final profileResponse = await Supabase.instance.client
//           .from('profiles')
//           .select('id')
//           .eq('auth_uid', authUid)
//           .maybeSingle();
//
//       if (profileResponse == null) {
//         print("⚠️ No profile found for auth uid: $authUid");
//         return [];
//       }
//
//       final profileId = profileResponse['id'] as String;
//
//       // 2. Query team_members + join teams table
//       final teamMembersResponse = await Supabase.instance.client
//           .from('team_members')
//           .select('teams(id, name)')
//           .eq('user_id', profileId);
//
//       if (teamMembersResponse.isEmpty) {
//         print("⚠️ No teams found for userId: $profileId");
//         return [];
//       }
//
//       // 3. Extract only team names
//       final teamNames = (teamMembersResponse as List)
//           .map((e) => (e['teams'] as Map<String, dynamic>)['name'] as String)
//           .toList();
//
//       print("✅ Team names: $teamNames");
//       return teamNames;
//     } catch (e) {
//       print("❌ Error getting user teams: $e");
//       return [];
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Tasks (${widget.memberName})'),
//         actions: [
//           ElevatedButton.icon(
//             onPressed: () => context.read<AuthCubit>().signOut(),
//             icon: const Icon(Icons.logout),
//             label: const Text("Logout"),
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () async {
//               await getUserTeamNames(widget.memberId);
//               context.read<TasksCubit>().loadTasks();
//             },
//           ),
//         ],
//       ),
//       body: BlocConsumer<TasksCubit, TasksState>(
//         listener: (context, state) {
//           if (state is TasksError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (_isLoadingTeams) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (state is TasksLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (state is TasksLoaded) {
//             // Filter tasks assigned to this member
//             final memberTasks = state.tasks.where((t) {
//               // Tasks assigned directly to this member
//               if (t.assigneeType == 'member' && t.assignee_names != null) {
//                 return t.assignee_names!.contains(widget.memberName);
//               }
//               // Tasks assigned to teams this member belongs to
//               else if (t.assigneeType == 'team' && t.assignee_names != null) {
//                 return _memberTeams.containsKey(t.assignee_names);
//               }
//               return false;
//             }).toList();
//
//             if (memberTasks.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.task, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text('No tasks assigned to you'),
//                     Text('Check back later for new assignments'),
//                   ],
//                 ),
//               );
//             }
//
//             return ListView.builder(
//               itemCount: memberTasks.length,
//               itemBuilder: (ctx, idx) {
//                 final t = memberTasks[idx];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   child: ListTile(
//                     title: Text(
//                       t.title,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         decoration: t.status == 'completed'
//                             ? TextDecoration.lineThrough
//                             : null,
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (t.description != null && t.description!.isNotEmpty)
//                           Text(
//                             t.description!,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         const SizedBox(height: 4),
//                         Wrap(
//                           spacing: 8,
//                           children: [
//                             Chip(
//                               label: Text(
//                                 t.status.toUpperCase(),
//                                 style: const TextStyle(fontSize: 10),
//                               ),
//                               backgroundColor: _getStatusColor(t.status),
//                             ),
//                             if (t.priority != null)
//                               Chip(
//                                 label: Text(
//                                   'P${t.priority}',
//                                   style: const TextStyle(fontSize: 10),
//                                 ),
//                                 backgroundColor: _getPriorityColor(t.priority!),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         if (t.assigneeType == 'team' && t.teamId != null)
//                           Text(
//                             'Team: ${_memberTeams[t.teamId] ?? 'Unknown Team'}',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         if (t.dueDate != null)
//                           Text(
//                             'Due: ${_formatDate(t.dueDate!)}',
//                             style: const TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                       ],
//                     ),
//                     trailing: PopupMenuButton(
//                       itemBuilder: (_) => [
//                         if (t.status != 'completed')
//                           const PopupMenuItem(
//                             value: 'complete',
//                             child: Text('Mark as Complete'),
//                           ),
//                         if (t.status == 'completed')
//                           const PopupMenuItem(
//                             value: 'reopen',
//                             child: Text('Reopen Task'),
//                           ),
//                       ],
//                       onSelected: (v) {
//                         if (v == 'complete') {
//                           context.read<TasksCubit>().updateTaskStatus(t.id, 'completed');
//                         } else if (v == 'reopen') {
//                           context.read<TasksCubit>().updateTaskStatus(t.id, 'todo');
//                         }
//                       },
//                     ),
//                     onTap: () => _showTaskDetails(context, t),
//                   ),
//                 );
//               },
//             );
//           }
//
//           if (state is TasksError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error, size: 64, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text('Error: ${state.message}'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => context.read<TasksCubit>().loadTasks(),
//                     child: const Text('Try Again'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return const Center(child: Text('No tasks found'));
//         },
//       ),
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'completed':
//         return Colors.green.shade100;
//       case 'in progress':
//         return Colors.blue.shade100;
//       case 'todo':
//         return Colors.orange.shade100;
//       default:
//         return Colors.grey.shade100;
//     }
//   }
//
//   Color _getPriorityColor(int priority) {
//     switch (priority) {
//       case 1:
//         return Colors.red.shade100;
//       case 2:
//         return Colors.orange.shade100;
//       case 3:
//         return Colors.yellow.shade100;
//       default:
//         return Colors.grey.shade100;
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
//
//   void _showTaskDetails(BuildContext context, TaskEntity task) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(task.title),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (task.description != null && task.description!.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: Text(task.description!),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: Row(
//                   children: [
//                     const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
//                     Chip(
//                       label: Text(task.status.toUpperCase()),
//                       backgroundColor: _getStatusColor(task.status),
//                     ),
//                   ],
//                 ),
//               ),
//               if (task.priority != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       const Text('Priority: ', style: TextStyle(fontWeight: FontWeight.bold)),
//                       Chip(
//                         label: Text('P${task.priority}'),
//                         backgroundColor: _getPriorityColor(task.priority!),
//                       ),
//                     ],
//                   ),
//                 ),
//               if (task.dueDate != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       const Text('Due Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text(_formatDate(task.dueDate!)),
//                     ],
//                   ),
//                 ),
//               if (task.assigneeType == 'team' && task.teamId != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       const Text('Team: ', style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text(_memberTeams[task.teamId] ?? 'Unknown Team'),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
import 'package:tasks/features/tasks/presentation/cubit/task_chat_cubit.dart';
import 'package:tasks/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks/features/tasks/presentation/task_details_page.dart';
import 'domain/entities/task_entity.dart';

class MemberTasksPage extends StatefulWidget {
  final String memberId; // auth_uid
  final String memberName;
  final Map<String, dynamic> currentUser; // 👈 full user profile

  const MemberTasksPage({
    required this.memberId,
    required this.memberName,
    required this.currentUser,
    super.key});

  @override
  State<MemberTasksPage> createState() => _MemberTasksPageState();
}

class _MemberTasksPageState extends State<MemberTasksPage> {
  Map<String, String> _memberTeams = {}; // team_id -> team_name
  bool _isLoadingTeams = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadMemberTeams();
      context.read<TasksCubit>().loadTasks();
    });
  }

  /// Load all teams this member belongs to
  Future<void> _loadMemberTeams() async {
    setState(() {
      _isLoadingTeams = true;
    });

    try {
      // 1. Find profile.id from auth_uid
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('auth_uid', widget.memberId)
          .maybeSingle();

      if (profileResponse == null) {
        print("⚠️ No profile found for auth uid: ${widget.memberId}");
        setState(() => _isLoadingTeams = false);
        return;
      }

      final profileId = profileResponse['id'] as String;

      // 2. Query team_members + join teams table
      final teamMembersResponse = await Supabase.instance.client
          .from('team_members')
          .select('team_id, teams(id, name)')
          .eq('user_id', profileId)
          .execute();

      if (teamMembersResponse.data == null || (teamMembersResponse.data as List).isEmpty) {
        print("⚠️ No teams found for userId: $profileId");
        setState(() => _isLoadingTeams = false);
        return;
      }

      // 3. Build a Map<team_id, team_name>
      final dataList = teamMembersResponse.data as List;
      _memberTeams = {
        for (var e in dataList)
          e['team_id'] as String: (e['teams'] as Map<String, dynamic>)['name'] as String
      };

      print("✅ Member teams loaded: $_memberTeams");
    } catch (e) {
      print("❌ Error loading member teams: $e");
    } finally {
      setState(() {
        _isLoadingTeams = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks (${widget.memberName})'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.read<AuthCubit>().signOut(),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadMemberTeams();
              context.read<TasksCubit>().loadTasks();
            },
          ),
        ],
      ),
      body: BlocConsumer<TasksCubit, TasksState>(
        listener: (context, state) {
          if (state is TasksError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (_isLoadingTeams || state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksLoaded) {
            // Filter tasks assigned to this member
            final memberTasks = state.tasks.where((t) {
              if (t.assigneeType == 'member' && t.assignee_names != null) {
                return t.assignee_names!.contains(widget.memberName);
              } else if (t.assigneeType == 'team'&& t.assignee_names != null ) {
                // return _memberTeams.containsValue(t.assignee_names);
                return t.assignee_names!.any((teamName) => _memberTeams.containsValue(teamName));

              }
              return false;
            }).toList();

            if (memberTasks.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No tasks assigned to you'),
                    Text('Check back later for new assignments'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: memberTasks.length,
              itemBuilder: (ctx, idx) {
                final t = memberTasks[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      t.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: t.status == 'completed'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (t.description != null && t.description!.isNotEmpty)
                          Text(
                            t.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        if (t.assigneeType == 'team' && t.teamId != null)
                          Text(
                            'Team: ${_memberTeams[t.teamId] ?? 'Unknown Team'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        if (t.status != 'completed')
                          const PopupMenuItem(
                            value: 'complete',
                            child: Text('Mark as Complete'),
                          ),
                        if (t.status == 'completed')
                          const PopupMenuItem(
                            value: 'reopen',
                            child: Text('Reopen Task'),
                          ),
                      ],
                      onSelected: (v) {
                        if (v == 'complete') {
                          context.read<TasksCubit>().updateTaskStatus(t.id, 'completed');
                        } else if (v == 'reopen') {
                          context.read<TasksCubit>().updateTaskStatus(t.id, 'todo');
                        }
                      },
                    ),
                    onTap: () => _showTaskDetails(context, t),
                  ),
                );
              },
            );
          }

          if (state is TasksError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TasksCubit>().loadTasks(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No tasks found'));
        },
      ),
    );
  }

  // void _showTaskDetails(BuildContext context, TaskEntity task) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text(task.title),
  //       content: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           if (task.description != null && task.description!.isNotEmpty)
  //             Padding(
  //               padding: const EdgeInsets.only(bottom: 8),
  //               child: Text(task.description!),
  //             ),
  //           if (task.assigneeType == 'team' && task.teamId != null)
  //             Text('Team: ${_memberTeams[task.teamId] ?? 'Unknown Team'}'),
  //           Text('Status: ${task.status}'),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(ctx).pop(),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  void _showTaskDetails(BuildContext context, TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TaskChatCubit(Supabase.instance.client)..subscribeToMessages(task.id),
          child: TaskDetailsPage(task: task,
            currentUser: widget.currentUser, // 👈 now works
          ),
        ),
      ),
    );

  }


}
