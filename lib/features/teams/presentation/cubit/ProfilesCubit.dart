import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilesCubit extends Cubit<List<Map<String, dynamic>>> {
  ProfilesCubit() : super([]);

  final supabase = Supabase.instance.client;

  Future<void> loadProfiles() async {
    if (state.isNotEmpty) return; // ✅ عندنا بيانات بالفعل

    try {
      final response = await supabase.from('profiles').select("*");
      emit(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print("Error loading profiles: $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await supabase.from('profiles').delete().eq('id', userId);
      // ✅ بعد الحذف نعيد تحميل القائمة
      final response = await supabase.from('profiles').select("*");
      emit(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  // Future<void> loadProfiles() async {
  //   try {
  //     // Fetch profiles from Supabase table
  //     final profiles = await Supabase.instance.client
  //         .from('profiles')
  //         .select();
  //
  //     final enrichedProfiles = <Map<String, dynamic>>[];
  //
  //     // Loop profiles and check verification once
  //     for (final user in profiles) {
  //       final authResponse = await Supabase.instance.client.auth.admin
  //           .getUserById(user['auth_uid']);
  //
  //       enrichedProfiles.add({
  //         ...user,
  //         'is_verified': authResponse.user?.emailConfirmedAt != null,
  //       });
  //     }
  //
  //     emit(enrichedProfiles);
  //   } catch (e, st) {
  //     print("Error loading profiles: $e");
  //     print(st);
  //   }
  // }

}

