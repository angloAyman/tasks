import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/Auth/presentation/EmailInputPage.dart';
import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigator.of(context).pushReplacementNamed('/tasks');
            // ✅ بعد النجاح في التسجيل نوديه على صفحة إدخال الإيميل عشان OTP
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>  EmailInputPage(
                  email:  _email.text.trim() ,
                ),
              ),
            );

          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                const SizedBox(height: 20),
                if (state is AuthLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text("Register"),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("Already have an account? Login"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
