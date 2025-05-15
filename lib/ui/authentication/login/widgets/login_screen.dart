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
      // Get the AuthServices instance from provider
      final authService = context.read<AuthServices>();
      // Call login method
      final result = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // if login success
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
    return Scaffold(
      // Removed AppBar for true screen centering; re-add if needed
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ), // Limit width for better appearance
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Minimize column size to fit content
                children: [
                  if (!_showResetForm) ...[
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _toggleResetForm,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _signIn,
                          child: const Text('Sign In'),
                        ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => context.go(Routes.signUp),
                      child: const Text('Create Account'),
                    ),
                  ] else ...[
                    TextField(
                      controller: _resetEmailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _sendPasswordResetEmail,
                          child: const Text('Send Reset Email'),
                        ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _toggleResetForm,
                      child: const Text('Back to Login'),
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
