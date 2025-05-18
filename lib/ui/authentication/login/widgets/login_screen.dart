import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/authentication/login/view_model/login_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child:
                  viewModel.showResetForm
                      ? _buildResetForm(viewModel)
                      : _buildLoginForm(viewModel),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(LoginViewModel viewModel) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(
            "Login Account",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            "Please login with registered account",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
          ),
          if (viewModel.hasError && viewModel.errorMessage != null) ...[
            const SizedBox(height: 20),
            _buildErrorMessage(viewModel),
          ],
          if (viewModel.resetSuccessMessage != null) ...[
            const SizedBox(height: 20),
            _buildSuccessMessage(viewModel),
          ],
          const SizedBox(height: 20),
          _buildEmailField(viewModel),
          const SizedBox(height: 15),
          _buildPasswordField(viewModel),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: viewModel.isLoading ? null : viewModel.toggleResetForm,
              child: const Text("Forgot Password?"),
            ),
          ),
          const SizedBox(height: 20),
          _buildSignInButton(viewModel),
          const SizedBox(height: 10),
          _buildSignUpLink(context),
        ],
      ),
    );
  }

  Widget _buildResetForm(LoginViewModel viewModel) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(
            "Reset Password",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            "Enter your email to receive a password reset link",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
          ),
          if (viewModel.hasError && viewModel.errorMessage != null) ...[
            const SizedBox(height: 20),
            _buildErrorMessage(viewModel),
          ],
          const SizedBox(height: 20),
          _buildResetEmailField(viewModel),
          const SizedBox(height: 20),
          _buildSendResetButton(viewModel),
          const SizedBox(height: 10),
          TextButton(
            onPressed: viewModel.isLoading ? null : viewModel.toggleResetForm,
            child: const Text("Back to Login"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(LoginViewModel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      enabled: !viewModel.isLoading,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        hintText: "Email Address",
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: viewModel.validateEmail,
    );
  }

  Widget _buildPasswordField(LoginViewModel viewModel) {
    return TextFormField(
      controller: viewModel.passwordController,
      obscureText: viewModel.obscurePassword,
      enabled: !viewModel.isLoading,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        hintText: "Password",
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: viewModel.togglePasswordVisibility,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: viewModel.validatePassword,
    );
  }

  Widget _buildResetEmailField(LoginViewModel viewModel) {
    return TextFormField(
      controller: viewModel.resetEmailController,
      enabled: !viewModel.isLoading,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        hintText: "Email Address",
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: viewModel.validateResetEmail,
    );
  }

  Widget _buildErrorMessage(LoginViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              viewModel.errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: Colors.red.shade700,
            onPressed: viewModel.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(LoginViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              viewModel.resetSuccessMessage!,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: Colors.green.shade700,
            onPressed: viewModel.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child:
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    final result = await viewModel.login();
                    if (result.isOk) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Logged in successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text("Sign In"),
              ),
    );
  }

  Widget _buildSendResetButton(LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child:
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () async {
                  if (_resetFormKey.currentState?.validate() == true) {
                    await viewModel.sendPasswordResetEmail();
                  }
                },
                child: const Text("Send Reset Email"),
              ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.push(Routes.signUp),
        child: Text(
          "Don't have an account? Sign Up Here",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color.fromARGB(255, 122, 53, 53),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
