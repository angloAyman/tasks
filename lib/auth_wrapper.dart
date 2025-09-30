
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart' as auth_cubit;
import 'package:tasks/features/tasks/MemberTasksPage.dart';
import 'package:tasks/home_page.dart';
import 'package:tasks/features/Auth/presentation/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/tasks/presentation/create_task_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // تاريخ انتهاء التطبيق
  static final DateTime expiryDate = DateTime(2025, 10, 20);



  /// جلب الدور واسم المستخدم من جدول profiles حسب auth_uid
  Future<Map<String, dynamic>?> _getUserProfile(String authUid) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('username, role, auth_uid')
        .eq('auth_uid', authUid)
        .maybeSingle();

    return response as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {

    // تحقق من تاريخ الانتهاء
    if (DateTime.now().isAfter(expiryDate)) {
      return const Scaffold(
        body: Center(
          child: Text(
            "❌ This app has expired.\nPlease contact the administrator.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return BlocBuilder<auth_cubit.AuthCubit, auth_cubit.AuthState>(
      builder: (context, state) {
        if (state is auth_cubit.AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is auth_cubit.AuthSuccess) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: _getUserProfile(state.user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final profile = snapshot.data;
              final role = profile?['role'] ?? 'member';
              final username = profile?['username'] ?? 'Unknown';

              // توجيه حسب الدور
              switch (role) {
                case 'admin':
                  return HomePage( currentUser: profile!,); // لوحة الإدارة
                case 'member':
                default:
                  return MemberTasksPage(
                    // username: username, // auth_uid
                    memberId: state.user.id, // auth_uid
                    memberName: username,
                    currentUser: profile!// الاسم من profile
                  );
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
