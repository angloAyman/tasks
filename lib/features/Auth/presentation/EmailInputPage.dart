//
//
// import 'package:flutter/material.dart';
// import 'package:tasks/data/datasources/supabase_service.dart';
// import 'package:tasks/features/Auth/presentation/OtpVerifyPage.dart' show OtpVerifyPage;
//
// class EmailInputPage extends StatefulWidget {
//   final String email; // 👈 استقبلها كـ final
//
//   const EmailInputPage({Key? key, required this.email}) : super(key: key);
//
//
//   @override
//   _EmailInputPageState createState() => _EmailInputPageState();
// }
//
// class _EmailInputPageState extends State<EmailInputPage> {
//   late final TextEditingController _emailController;
//   final SupabaseService _supabaseService = SupabaseService();
//
//
//   @override
//   void initState() {
//     super.initState();
//     _emailController = TextEditingController(text: widget.email); // 👈 خليها معبّاة بالإيميل
//   }
//
//
//   void _sendOtp() async {
//     final email = _emailController.text.trim();
//     if (email.isEmpty) return;
//
//     await _supabaseService.sendOtp(_emailController.text);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => OtpVerifyPage(email: _emailController.text),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Verify Email")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: _sendOtp, child: Text("Send OTP")),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:tasks/data/datasources/supabase_service.dart';
import 'package:tasks/features/Auth/presentation/OtpVerifyPage.dart' show OtpVerifyPage;

class EmailInputPage extends StatefulWidget {
  final String email;

  const EmailInputPage({Key? key, required this.email}) : super(key: key);

  @override
  _EmailInputPageState createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  late final TextEditingController _emailController;
  final SupabaseService _supabaseService = SupabaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final success = await _supabaseService.sendOtp(email);

      if (mounted) {
        if (success) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerifyPage(email: email),
            ),
          );
        } else {
          setState(() {
            _errorMessage = "Failed to send OTP. Please try again.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An error occurred: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Enter your email",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We'll send you a verification code to this email",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email address",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!_isValidEmail(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _sendOtp(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Text(
                      "Send Verification Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // TextButton(
                //   onPressed: _isLoading
                //       ? null
                //       : () {
                //     _emailController.clear();
                //     if (_formKey.currentState != null) {
                //       _formKey.currentState!.reset();
                //     }
                //   },
                //   child: const Text("Clear"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}