import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/teams/domain/entities/team_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamsCubit extends Cubit<List<TeamEntity>> {
  TeamsCubit() : super([]);

  final supabase = Supabase.instance.client;

  // Future<void> loadTeams() async {
  //   final response = await supabase.from('teams').select();
  //   final teams = (response as List).map((t) {
  //     return TeamEntity(
  //       id: t['id'],
  //       name: t['name'],
  //       description: t['description'],
  //       createdAt: DateTime.parse(t['created_at']),
  //     );
  //   }).toList();
  //   emit(teams);
  // }

  Future<List<TeamEntity>> loadTeams() async {
    try {
      final response = await supabase.from('teams').select();

      if (response is List) {
        final teams = response.map((t) {
          return TeamEntity(
            id: t['id'] as String,
            name: t['name'] as String,
            description: t['description'] as String?,
            createdAt: DateTime.tryParse(t['created_at'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        emit(teams);
        return teams; // ✅ return teams if loaded
      }
      emit([]);
      return [];
    } catch (e, st) {
      print("❌ Error loading teams: $e\n$st");
      emit([]);
      return [];
    }
  }




  Future<void> addTeam(String name, String? desc) async {
    final response = await supabase.from('teams').insert({
      'name': name,
      'description': desc,
    }).select().single();

    final newTeam = TeamEntity(
      id: response['id'],
      name: response['name'],
      description: response['description'],
      createdAt: DateTime.parse(response['created_at']),
    );

    emit([...state, newTeam]);
  }

  Future<void> deleteTeam(String id) async {
    try {
      // حذف الفريق من Supabase
      await supabase.from('teams').delete().eq('id', id);

      // تحديث الحالة بعد الحذف
      final updatedTeams = state.where((t) => t.id != id).toList();
      emit(updatedTeams);
    } catch (e) {
      print("Error deleting team: $e");
    }
  }

}