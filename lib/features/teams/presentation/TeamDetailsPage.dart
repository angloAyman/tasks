import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/teams/domain/entities/team_entity.dart';
import 'package:tasks/features/teams/domain/entities/member_entity.dart';
import 'package:tasks/features/teams/presentation/cubit/members_cubit.dart';

// class TeamDetailsPage extends StatefulWidget {
//   final TeamEntity team;
//
//   const TeamDetailsPage({super.key, required this.team});
//
//   @override
//   State<TeamDetailsPage> createState() => _TeamDetailsPageState();
// }
//
// class _TeamDetailsPageState extends State<TeamDetailsPage>
//     with AutomaticKeepAliveClientMixin{
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     return BlocProvider(
//       create: (_) =>
//       MembersCubit()
//         ..loadMembers(widget.team.id),
//       child: Builder( // 👈 this ensures context has the provider
//         builder: (context) {
//           return Scaffold(
//             appBar: AppBar(title: Text("Team: ${widget.team.name}")),
//             body: BlocBuilder<MembersCubit, List<MemberEntity>>(
//               builder: (context, members) {
//                 if (members.isEmpty) {
//                   return const Center(child: Text("No members yet"));
//                 }
//                 return ListView.builder(
//                   itemCount: members.length,
//                   itemBuilder: (context, index) {
//                     final member = members[index];
//                     return ListTile(
//                       leading: const CircleAvatar(child: Icon(Icons.person)),
//                       title: Text(member.username ?? member.userId),
//                       subtitle: Text(
//                         "Role: ${member.role}\n${member.email ?? ''}",
//                       ),
//                       isThreeLine: true,
//                       trailing: IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           context.read<MembersCubit>().deleteMember(member.id);
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//             floatingActionButton: FloatingActionButton(
//               onPressed: () async {
//                 final membersCubit = context.read<
//                     MembersCubit>(); // ✅ now works
//                 final allUsers = await membersCubit.fetchAllUsers();
//
//                 String? selectedUserId;
//                 String? selectedUsername;
//                 String? selectedEmail;
//                 final roleController = TextEditingController(text: "member");
//
//                 await showDialog(
//                   context: context,
//                   builder: (ctx) {
//                     return StatefulBuilder(
//                       builder: (ctx, setState) {
//                         return AlertDialog(
//                           title: const Text("Add Member"),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               DropdownButtonFormField<String>(
//                                 decoration: const InputDecoration(
//                                     labelText: "Select User"),
//                                 items: allUsers.map<DropdownMenuItem<String>>((
//                                     user) {
//                                   return DropdownMenuItem<String>(
//                                     value: user['id'],
//                                     child: Text(
//                                         "${user['username']} (${user['email']})"),
//                                   );
//                                 }).toList(),
//                                 onChanged: (value) {
//                                   final user = allUsers.firstWhere((
//                                       u) => u['id'] == value);
//                                   setState(() {
//                                     selectedUserId = user['id'];
//                                     selectedUsername = user['username'];
//                                     selectedEmail = user['email'];
//                                   });
//                                 },
//                               ),
//                               TextField(
//                                 controller: roleController,
//                                 decoration: const InputDecoration(
//                                     labelText: "Role"),
//                               ),
//                             ],
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(ctx),
//                               child: const Text("Cancel"),
//                             ),
//                             ElevatedButton(
//                               onPressed: selectedUserId == null
//                                   ? null
//                                   : () {
//                                 membersCubit.addMember(
//                                   widget.team.id,
//                                   selectedUserId!,
//                                   role: roleController.text,
//                                   // username: selectedUsername ?? "",
//                                   // email: selectedEmail ?? "",
//                                 );
//                                 Navigator.pop(ctx);
//                               },
//                               child: const Text("Add"),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//               child: const Icon(Icons.person_add),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//
//
//   @override
//   bool get wantKeepAlive => true;
// }


class TeamDetailsPage extends StatefulWidget {
  final TeamEntity team;

  const TeamDetailsPage({super.key, required this.team});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage>
    with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: Text("Team: ${widget.team.name}")),
      body: BlocBuilder<MembersCubit, List<MemberEntity>>(
        builder: (context, members) {
          if (members.isEmpty) {
            return const Center(child: Text("No members yet"));
          }
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(member.username ?? member.userId),
                subtitle: Text(
                  "Role: ${member.role}\n${member.email ?? ''}",
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    context.read<MembersCubit>().deleteMember(member.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final membersCubit = context.read<MembersCubit>();
          final allUsers = await membersCubit.fetchAllUsers();

          String? selectedUserId;
          final roleController = TextEditingController(text: "member");

          await showDialog(
            context: context,
            builder: (ctx) {
              return StatefulBuilder(
                builder: (ctx, setState) {
                  return AlertDialog(
                    title: const Text("Add Member"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Select User"),
                          items: allUsers.map<DropdownMenuItem<String>>((user) {
                            return DropdownMenuItem<String>(
                              value: user['id'],
                              child: Text("${user['username']} (${user['email']})"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedUserId = value;
                            });
                          },
                        ),
                        TextField(
                          controller: roleController,
                          decoration: const InputDecoration(labelText: "Role"),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: selectedUserId == null
                            ? null
                            : () {
                          membersCubit.addMember(
                            widget.team.id,
                            selectedUserId!,
                            role: roleController.text,
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
