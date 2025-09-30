import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks/data/repositories/task_repository_impl.dart';
import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
import 'package:tasks/features/Auth/presentation/login_page.dart';
import 'package:tasks/features/Auth/presentation/register_page.dart';
import 'package:tasks/features/tasks/data/datasource/NotificationService.dart';
import 'package:tasks/home_page.dart';
import 'package:tasks/splash_page.dart';
import 'package:tasks/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:tasks/features/tasks/presentation/tasks_page.dart';
import 'package:permission_handler/permission_handler.dart';

import 'data/datasources/supabase_service.dart';
import 'features/teams/presentation/cubit/ProfilesCubit.dart';
import 'features/teams/presentation/cubit/teams_cubit.dart';
import 'features/teams/presentation/teams_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  await Supabase.initialize(
    url: 'https://jobfwkvaieiajwvjmxuq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpvYmZ3a3ZhaWVpYWp3dmpteHVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3MjMxMTEsImV4cCI6MjA3MzI5OTExMX0.mMLKGzmvs4Q0SwmoaXfembGs1aRZbnt3EHvO5CM3hgU',
  );

  final supabaseService = SupabaseService();

  runApp(MyApp(supabaseService: supabaseService));
}

class MyApp extends StatefulWidget {
  final SupabaseService supabaseService;

  const MyApp({super.key, required this.supabaseService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }



  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers:
      [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(SupabaseService())..checkAuthStatus(),
        ),
        BlocProvider<TasksCubit>(
          create: (_) => TasksCubit(
            TaskRepositoryImpl(SupabaseService()),
          )..loadTasks(),
        ),
        BlocProvider(create: (_) => TeamsCubit()..loadTeams(),
          child: const TeamsPage(),

        ),

        BlocProvider<ProfilesCubit>(
          create: (_) => ProfilesCubit()..loadProfiles(),
        ),



      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tasks App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashPage(),
        routes: {
          '/login': (_) =>  LoginPage(),
          '/register': (_) =>  RegisterPage(),

          '/home': (_) =>  HomePage(currentUser: {},),

          // '/tasks': (_) =>  TasksPage(),



          // '/admin-dashboard': (_) =>  HomePage(currentUser: ,),



        },
      ),
    );
  }
}
