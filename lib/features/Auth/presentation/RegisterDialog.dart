import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/Auth/presentation/EmailInputPage.dart';
import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
import 'package:tasks/home_page.dart';
import 'package:tasks/home_page.dart';

class RegisterDialog extends StatefulWidget {

  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  void _register() {
    context.read<AuthCubit>().signUp(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
      phone: _phone.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccesss) {
          Navigator.pop(context); // اغلق الديالوج
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User created successfully")),
          );
        // if (state is AuthSuccess) {
        //   Navigator.pop(context); // اغلق الديالوج
        //   // Navigator.push(
        //   //   context,
        //   //   MaterialPageRoute(
        //   //     builder: (_) =>  HomePage( currentUser: profile!,),
        //   //     // builder: (_) =>  EmailInputPage(),
        //   //   ),
        //   // );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text("Register New Member"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _username,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: state is AuthLoading ? null : _register,
              child: state is AuthLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Register"),
            ),
          ],
        );
      },
    );
  }
}
