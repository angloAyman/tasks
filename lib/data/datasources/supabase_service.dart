import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;
  SupabaseService() : client = Supabase.instance.client;

  // Auth sign up
  Future<AuthResponse> signUp(String email, String password) {
    return client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => client.auth.signOut();




  // Profiles CRUD
  Future<PostgrestResponse> createProfile(Map<String, dynamic> profile) {
    return client.from('profiles').insert(profile).execute();
  }

  Future<List<Map<String, dynamic>>> getProfileByAuthUid(String authUid) async {
    final res = await client.from('profiles').select().eq('auth_uid', authUid).maybeSingle();
    if (res == null) return [];
    return [res];
  }





  // Tasks CRUD
  Future<PostgrestResponse> createTask(Map<String, dynamic> task) {
    return client.from('tasks').insert(task).execute();
  }

  Future<List<Map<String, dynamic>>> fetchTasks({String? teamId}) async {
    final response = await client.from('tasks').select('*').order('created_at', ascending: false).execute();
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<PostgrestResponse> updateTask(String id, Map<String, dynamic> data) {
    return client.from('tasks').update(data).eq('id', id).execute();
  }

  Future<PostgrestResponse> deleteTask(String id) {
    return client.from('tasks').delete().eq('id', id).execute();
  }

  Future<bool> sendOtp(String email) async {
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true, // يعمل حساب جديد لو مش موجود
      );
      print("OTP sent to $email ✅");
      return true;
    } catch (e) {
      print("Error sending OTP: $e");
      return false;
    }
  }

  // Future<void> verifyOtp(String email, String token) async {
  //   try {
  //     final response = await Supabase.instance.client.auth.verifyOTP(
  //       type: OtpType.email,
  //       email: email,
  //       token: token, // الكود اللي المستخدم كتبه
  //     );
  //
  //
  //     if (response.user != null) {
  //       print("Email verified ✅ User logged in: ${response.user!.email}");
  //     } else {
  //       print("Verification failed ❌");
  //     }
  //   } catch (e) {
  //     print("Error verifying OTP: $e");
  //   }
  // }
  Future<bool> verifyOtp(String email, String token) async {
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token, // الكود اللي المستخدم كتبه
      );

      if (response.user != null) {
        final user = response.user!;
        print("Email verified ✅ User logged in: ${user.email}");

        // ✅ تحديث is_verified = true في جدول profiles
        await Supabase.instance.client
            .from('profiles')
            .update({'is_verified': true})
            .eq('auth_uid', user.id);

        print("Profile updated ✅ is_verified set to true for ${user.email}");
     return true;
      } else {
        print("Verification failed ❌");
        return false ;
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      return false ;
    }
  }


  Session? getCurrentSession() {
    return client.auth.currentSession;
  }


  // Future<void> restoreSession(Session currentSession) async {
  //   await client.auth.setSession(currentSession);
  // }

  // Future<void> restoreSession(Session currentSession) async {
  //   await client.auth.setSession(
  //     currentSession.accessToken,
  //     currentSession.refreshToken,
  //   );
  // }



}
