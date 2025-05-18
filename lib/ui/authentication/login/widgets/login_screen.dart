import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController();
  String? _errorMessage;
  String? _resetSuccessMessage;
  bool _isLoading = false;
  bool _showResetForm = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resetSuccessMessage = null;
    });

    try {
      final authService = context.read<AuthServices>();
      final result = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.isError) {
        setState(() {
          _errorMessage = _parseErrorMessage(result.asError.error.toString());
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resetSuccessMessage = null;
    });

    try {
      final authService = context.read<AuthServices>();
      final result = await authService.sendPasswordResetEmail(
        email: _resetEmailController.text.trim(),
      );

      if (result.isOk) {
        setState(() {
          _resetSuccessMessage = 'Password reset email sent. Check your inbox.';
          _showResetForm = false;
          _resetEmailController.clear();
        });
      } else {
        setState(() {
          _errorMessage = _parseErrorMessage(result.asError.error.toString());
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _parseErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No user found with this email.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email format.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  void _toggleResetForm() {
    setState(() {
      _showResetForm = !_showResetForm;
      _errorMessage = null;
      _resetSuccessMessage = null;
      _resetEmailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _showResetForm ? "Reset Password" : "Login Account",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showResetForm
                        ? "Enter your email to receive a password reset link"
                        : "Please login with registered account",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  if (!_showResetForm) ...[
                    TextField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _toggleResetForm,
                        child: const Text("Forgot Password?"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account yet? "),
                        GestureDetector(
                          onTap: () => context.push(Routes.signUp),
                          child: const Text(
                            "Create one",
                            style: TextStyle(
                              color: Color.fromARGB(255, 122, 53, 53),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    TextField(
                      controller: _resetEmailController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _sendPasswordResetEmail,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Send Reset Email",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isLoading ? null : _toggleResetForm,
                      child: const Text("Back to Login"),
                    ),
                  ],

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  if (_resetSuccessMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _resetSuccessMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
