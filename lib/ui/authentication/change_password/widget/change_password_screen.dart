import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/change_password/view_model/change_password_view_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  final ChangePasswordViewModel viewModel = ChangePasswordViewModel();

  ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _oldPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    widget.viewModel.oldPasswordController.dispose();
    widget.viewModel.newPasswordController.dispose();
    widget.viewModel.confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      _oldPasswordError = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await widget.viewModel.changePassword(
        oldPassword: widget.viewModel.oldPasswordController.text.trim(),
        newPassword: widget.viewModel.newPasswordController.text.trim(),
        confirmNewPassword:
            widget.viewModel.confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result.isOk) {
        Navigator.of(context).pop(); // Go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = result.asError.error.toString();
        print('Error received: $error');

        if (error.toLowerCase().contains('auth credential is incorrect')) {
          setState(() {
            _oldPasswordError = 'Incorrect old password';
            widget.viewModel.oldPasswordController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to change password: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildOldPasswordField() {
    return TextFormField(
      controller: widget.viewModel.oldPasswordController,
      obscureText: widget.viewModel.obscureOldPassword,
      decoration: InputDecoration(
        hintText: "Old Password",
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            widget.viewModel.obscureOldPassword
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              widget.viewModel.toggleOldPasswordVisibility();
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your old password';
        }
        return null;
      },
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: widget.viewModel.newPasswordController,
      obscureText: widget.viewModel.obscureNewPassword,
      decoration: InputDecoration(
        hintText: "New Password",
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            widget.viewModel.obscureNewPassword
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              widget.viewModel.toggleNewPasswordVisibility();
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: widget.viewModel.validateNewPassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: widget.viewModel.confirmPasswordController,
      obscureText: widget.viewModel.obscureConfirmPassword,
      decoration: InputDecoration(
        hintText: "Confirm New Password",
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            widget.viewModel.obscureConfirmPassword
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              widget.viewModel.toggleConfirmPasswordVisibility();
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: widget.viewModel.validateConfirmPassword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOldPasswordField(),
              if (_oldPasswordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    _oldPasswordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              _buildNewPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Change'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
