import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/authentication/signup/view_model/signup_viewmodel.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key, required this.viewModel});
  final SignUpViewmodel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: const _SignupScreenContent(),
    );
  }
}

class _SignupScreenContent extends StatefulWidget {
  const _SignupScreenContent();

  @override
  State<_SignupScreenContent> createState() => _SignupScreenContentState();
}

class _SignupScreenContentState extends State<_SignupScreenContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewmodel>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  "Create An Account",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  "Sign Up for Exclusive Crochet Designs & Offers",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                ),
                if (viewModel.hasError && viewModel.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  _buildErrorMessage(viewModel),
                ],
                const SizedBox(height: 20),
                _buildFirstNameField(viewModel),
                const SizedBox(height: 15),
                _buildLastNameField(viewModel),
                const SizedBox(height: 15),
                _buildPhoneField(viewModel),
                const SizedBox(height: 15),
                _buildEmailField(viewModel),
                const SizedBox(height: 15),
                _buildPasswordField(viewModel),
                const SizedBox(height: 15),
                _buildConfirmPasswordField(viewModel),
                const SizedBox(height: 20),
                _buildSignUpButton(viewModel),
                const SizedBox(height: 10),
                _buildSignInLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstNameField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.firstNameController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: "First Name",
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        prefixIcon: Icon(Icons.person),
      ),
      validator: viewModel.validateName,
    );
  }

  Widget _buildLastNameField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.lastNameController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        hintText: "Last Name",
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: viewModel.validateName,
    );
  }

  Widget _buildPhoneField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.phoneController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _PhoneNumberFormatter(),
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.phone),
        hintText: "010-1234567",
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: viewModel.validatePhone,
    );
  }

  Widget _buildEmailField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        hintText: "Email Address",
        filled: true,
        fillColor: Colors.grey.shade50,
      ),

      validator: viewModel.validateEmail,
    );
  }

  Widget _buildPasswordField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.passwordController,
      obscureText: viewModel.obscurePassword,
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: viewModel.togglePasswordVisibility,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: viewModel.validatePassword,
    );
  }

  Widget _buildConfirmPasswordField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.confirmPasswordController,
      obscureText: viewModel.obscureConfirmPassword,
      decoration: InputDecoration(
        hintText: "Confirm Password",
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscureConfirmPassword
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: viewModel.toggleConfirmPasswordVisibility,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: viewModel.validateConfirmPassword,
    );
  }

  Widget _buildErrorMessage(SignUpViewmodel viewModel) {
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

  Widget _buildSignUpButton(SignUpViewmodel viewModel) {
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
                    final result = await viewModel.signUp();
                    if (result.isOk) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Account created successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.push(Routes.login);
                      }
                    }
                  }
                },
                child: const Text("Sign Up"),
              ),
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.push(Routes.login),
        child: Text(
          "Already have an account? Sign In Here",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Color.fromARGB(255, 122, 53, 53),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Custom formatter to insert `-` after third digit
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('-', '');
    if (digits.length <= 3) return newValue.copyWith(text: digits);

    final formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
