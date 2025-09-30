// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
//
// import '../../teams/presentation/cubit/ProfilesCubit.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _email = TextEditingController();
//   final _password = TextEditingController();
//
//   void _login() {
//     context.read<AuthCubit>().signIn(_email.text.trim(), _password.text.trim());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: MultiBlocListener(
//         listeners: [
//           // Listen for authentication success
//           BlocListener<AuthCubit, AuthState>(
//             listener: (context, state) {
//               if (state is AuthSuccess) {
//                 // Load profiles to get user role information
//                 context.read<ProfilesCubit>().loadProfiles();
//               } else if (state is AuthFailure) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(state.message)),
//                 );
//               }
//             },
//           ),
//           // Listen for profiles loaded to check user role
//           BlocListener<ProfilesCubit, List<Map<String, dynamic>>>(
//             listener: (context, profiles) {
//               final authState = context.read<AuthCubit>().state;
//
//               if (authState is AuthSuccess) {
//                 // Find the user's profile based on auth UID
//                 final userProfile = profiles.firstWhere(
//                       (profile) => profile['auth_uid'] == authState.user.id,
//                   orElse: () => {},
//                 );
//
//                 // Navigate based on user role
//                 if (userProfile.isNotEmpty) {
//                   final userRole = userProfile['role'] ?? 'member';
//
//                   if (userRole == 'admin') {
//                     // Navigate to admin dashboard
//                     Navigator.of(context).pushReplacementNamed('/admin-dashboard');
//                   } else {
//                     // Navigate to regular tasks page for members
//                     Navigator.of(context).pushReplacementNamed('/tasks');
//                   }
//                 } else {
//                   // Default navigation if profile not found
//                   Navigator.of(context).pushReplacementNamed('/tasks');
//                 }
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<AuthCubit, AuthState>(
//           builder: (context, state) {
//             return Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _email,
//                     decoration: const InputDecoration(labelText: "Email"),
//                     keyboardType: TextInputType.emailAddress,
//                   ),
//                   TextField(
//                     controller: _password,
//                     decoration: const InputDecoration(labelText: "Password"),
//                     obscureText: true,
//                   ),
//                   const SizedBox(height: 20),
//                   if (state is AuthLoading)
//                     const CircularProgressIndicator()
//                   else
//                     ElevatedButton(
//                       onPressed: _login,
//                       child: const Text("Login"),
//                     ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushReplacementNamed(context, '/register');
//                     },
//                     child: const Text("Don't have an account? Register"),
//                   )
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks/features/Auth/presentation/cubit/auth_cubit.dart';
import '../../teams/presentation/cubit/ProfilesCubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                context.read<ProfilesCubit>().loadProfiles();
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          BlocListener<ProfilesCubit, List<Map<String, dynamic>>>(
            listener: (context, profiles) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthSuccess) {
                final userProfile = profiles.firstWhere(
                      (profile) => profile['auth_uid'] == authState.user.id,
                  orElse: () => {},
                );

                if (userProfile.isNotEmpty) {
                  final userRole = userProfile['role'] ?? 'member';
                  if (userRole == 'admin') {
                    Navigator.of(context).pushReplacementNamed('/admin-dashboard');
                  } else {
                    Navigator.of(context).pushReplacementNamed('/tasks');
                  }
                } else {
                  Navigator.of(context).pushReplacementNamed('/tasks');
                }
              }
            },
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade500,
                Colors.blue.shade300,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Welcome Section
                  _buildWelcomeSection(),

                  const SizedBox(height: 40),

                  // Login Form
                  _buildLoginForm(),

                  const SizedBox(height: 24),

                  // Additional Options
                  _buildAdditionalOptions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.task_alt,
            size: 40,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to continue to your tasks',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
            ),

            const SizedBox(height: 8),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Implement forgot password functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forgot password functionality to be implemented'),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Login Button
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        // Divider with "or" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.white.withOpacity(0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.white.withOpacity(0.3),
                thickness: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Register Button
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/register');
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
          ),
          child: const Text(
            "Create New Account",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Quick Demo Login (optional)
        TextButton(
          onPressed: () {
            // Pre-fill demo credentials
            _emailController.text = 'demo@example.com';
            _passwordController.text = 'password123';
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Demo credentials filled. Click Sign In to continue.'),
                backgroundColor: Colors.blue,
              ),
            );
          },
          child: Text(
            'Try Demo Account',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}