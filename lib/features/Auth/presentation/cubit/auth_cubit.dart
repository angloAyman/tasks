import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks/data/datasources/supabase_service.dart';
import 'package:uuid/uuid.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SupabaseService supabaseService;
  AuthCubit(this.supabaseService) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final session = supabaseService.getCurrentSession();
      if (session != null && session.user != null) {
        emit(AuthSuccess(session.user));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  // Future<void> signUp({
  //   required String username,
  //   required String email,
  //   required String password,
  //   String? phone,
  //   String role = 'member'
  // }) async {
  //   emit(AuthLoading());
  //   try {
  //     final res = await supabaseService.signUp(email, password);
  //     final user = res.user;
  //     if (user == null) {
  //       emit(AuthFailure('Signup failed'));
  //       return;
  //     }
  //     // create profile in profiles table
  //     final profile = {
  //       'auth_uid': user.id,
  //       'username': username,
  //       'email': email,
  //       'phone': phone,
  //       'role': role,
  //       'is_verified': false
  //     };
  //     await supabaseService.createProfile(profile);
  //     emit(AuthInitial());
  //   } catch (e) {
  //     emit(AuthFailure(e.toString()));
  //   }
  // }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    String? phone,
    String role = 'member',
  }) async {
    emit(AuthLoading());
    try {
      final res = await supabaseService.signUp(email, password);

      final user = res.user;
      if (user == null) {
        emit(AuthFailure('Signup failed'));
        return;
      }

      // 👇 أضف البروفايل في جدول profiles
      final profile = {
        'auth_uid': user.id,
        'username': username,
        'email': email,
        'phone': phone,
        'role': role,
        'is_verified': false,
      };
      await supabaseService.createProfile(profile);

      // ✅ هنا ما بنعملش emit(AuthSuccess)

      emit(AuthSuccesss()); // أو AuthCreatedSuccess مثلاً
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }





  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final res = await supabaseService.signIn(email, password);
      final user = res.user;
      if (user!= null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure('Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    await supabaseService.signOut();
    emit(AuthInitial());
  }
}
