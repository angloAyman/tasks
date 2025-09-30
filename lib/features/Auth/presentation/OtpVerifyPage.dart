// import 'package:flutter/material.dart';
//
// import '../../../data/datasources/supabase_service.dart';
//
// class OtpVerifyPage extends StatefulWidget {
//   final String email;
//   const OtpVerifyPage({super.key, required this.email});
//
//   @override
//   _OtpVerifyPageState createState() => _OtpVerifyPageState();
// }
//
// class _OtpVerifyPageState extends State<OtpVerifyPage> {
//   final _otpController = TextEditingController();
//   final SupabaseService _supabaseService = SupabaseService();
//
//   void _verifyOtp() async {
//     final token = _otpController.text.trim();
//     if (token.isEmpty) return;
//
//     await _supabaseService.verifyOtp(widget.email, _otpController.text);
//     // لو ناجح → روح للصفحة الرئيسية
//     Navigator.pushReplacementNamed(context, "/home");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Enter OTP")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text("Check your email for a 6-digit OTP code"),
//             TextField(controller: _otpController, decoration: InputDecoration(labelText: "OTP Code")),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: _verifyOtp, child: Text("Verify")),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:tasks/data/datasources/supabase_service.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;

  const OtpVerifyPage({super.key, required this.email});

  @override
  _OtpVerifyPageState createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final SupabaseService _supabaseService = SupabaseService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCooldown = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _setupOtpFields();
    _startResendCooldown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _setupOtpFields() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && _otpControllers[i].text.isEmpty) {
          if (i > 0) _focusNodes[i - 1].requestFocus();
        }
      });
    }
  }

  void _startResendCooldown() {
    _resendCooldown = 30; // 30 seconds cooldown
    _canResend = false;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCooldown--;
        });
        if (_resendCooldown > 0) {
          _startResendCooldown();
        } else {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final otpCode = _getOtpCode();
    if (otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a complete 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _supabaseService.verifyOtp(widget.email, otpCode);

      if (mounted) {
        if (result) {
          // Successfully verified - navigate to home
          Navigator.pushReplacementNamed(context, "/home");
        } else {
          setState(() {
            _errorMessage = "Verification failed. Please try again.";
          });
          // Clear OTP fields on failure
          _clearOtpFields();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An unexpected error occurred. Please try again.";
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

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _errorMessage = null;
    });

    final result = await _supabaseService.sendOtp(widget.email);

    if (mounted) {
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP resent to ${widget.email}"),
            backgroundColor: Colors.green,
          ),
        );
        _clearOtpFields();
        _startResendCooldown();
      } else {
        setState(() {
          _errorMessage =  "Failed to resend OTP. Please try again.";
        });
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
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
                  "Enter verification code",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    children: [
                      const TextSpan(text: "We sent a 6-digit code to "),
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _errorMessage != null ? Colors.red : Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _errorMessage != null ? Colors.red : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                        onChanged: (value) => _onOtpChanged(value, index),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),
                    );
                  }),
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

                const SizedBox(height: 24),

                // Resend OTP Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    _canResend
                        ? TextButton(
                      onPressed: _resendOtp,
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                        : Text(
                      "Resend in $_resendCooldown",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
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
                      "Verify Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Clear Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: _isLoading ? null : _clearOtpFields,
                    child: const Text("Clear Code"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}