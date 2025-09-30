# tasks

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#
lib/
├─ core/
│  ├─ error/
│  ├─ utils/
├─ data/
│  ├─ models/
│  │  ├─ user_model.dart
│  │  ├─ task_model.dart
│  ├─ datasources/
│  │  ├─ supabase_service.dart
│  ├─ repositories/
│  │  ├─ task_repository_impl.dart
├─ domain/
│  ├─ entities/
│  │  ├─ user_entity.dart
│  │  ├─ task_entity.dart
│  ├─ repositories/
│  │  ├─ task_repository.dart
│  ├─ usecases/
│  │  ├─ create_task.dart
├─ presentation/
│  ├─ cubit/
│  │  ├─ auth_cubit.dart
│  │  ├─ tasks_cubit.dart
│  ├─ pages/
│  │  ├─ splash_page.dart
│  │  ├─ login_page.dart
│  │  ├─ register_page.dart
│  │  ├─ tasks_page.dart
│  │  ├─ create_task_page.dart
├─ main.dart
