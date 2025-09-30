import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks/features/teams/domain/entities/member_entity.dart';

class MembersCubit extends Cubit<List<MemberEntity>> {
  MembersCubit() : super([]);

  final supabase = Supabase.instance.client;

  Future<void> loadMembers(String teamId) async {
    final response = await supabase
        .from('team_members')
        .select('id, team_id, user_id, role, joined_at, profiles(username, email)')
        .eq('team_id', teamId);

    final members = (response as List).map((m) {
      return MemberEntity(
        id: m['id'],
        teamId: m['team_id'],
        userId: m['user_id'],
        role: m['role'],
        joinedAt: DateTime.parse(m['joined_at']),
        // نضيف بيانات البروفايل
        username: m['profiles']?['username'],
        email: m['profiles']?['email'],
      );
    }).toList();

    emit(members);
  }

  Future<void> addMember(
      String teamId,
      String userId, {
        String role = 'member',
      }) async {
    final response = await supabase.from('team_members').insert({
      'team_id': teamId,
      'user_id': userId,
      'role': role,
    }).select('id, team_id, user_id, role, joined_at, profiles(username, email)').single();

    final newMember = MemberEntity(
      id: response['id'],
      teamId: response['team_id'],
      userId: response['user_id'],
      role: response['role'],
      joinedAt: DateTime.parse(response['joined_at']),
      username: response['profiles']?['username'],
      email: response['profiles']?['email'],
    );

    emit([...state, newMember]);
  }

  Future<void> deleteMember(String memberId) async {
    await supabase.from('team_members').delete().eq('id', memberId);
    emit(state.where((m) => m.id != memberId).toList());
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final response = await supabase.from('profiles').select('id, username, email');
    return (response as List).map((u) => {
      'id': u['id'],
      'username': u['username'],
      'email': u['email'],
    }).toList();
  }


}
