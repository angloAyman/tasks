// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tasks/features/teams/domain/entities/member_entity.dart';
// import 'package:tasks/features/teams/presentation/cubit/members_cubit.dart';
//
// class MembersPage extends StatelessWidget {
//   final String teamId;
//   const MembersPage({super.key, required this.teamId});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<MembersCubit, List<MemberEntity>>(
//       builder: (context, members) {
//         return Scaffold(
//           appBar: AppBar(title: const Text('Members')),
//           body: ListView.builder(
//             itemCount: members.length,
//             itemBuilder: (context, index) {
//               final member = members[index];
//               return ListTile(
//                 title: Text(member.userId), // هتحتاج تجيب اسم من profiles
//                 subtitle: Text(member.role),
//               );
//             },
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               // مثال: إضافة عضو جديد
//               context.read<MembersCubit>().addMember(teamId, "some-user-id");
//             },
//             child: const Icon(Icons.person_add),
//           ),
//         );
//       },
//     );
//   }
// }
