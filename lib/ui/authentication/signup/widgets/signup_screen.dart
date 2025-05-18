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
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
                ),
                const SizedBox(height: 30),
                _buildNameFields(viewModel),
                const SizedBox(height: 15),
                _buildPhoneField(viewModel),
                const SizedBox(height: 15),
                _buildEmailField(viewModel),
                const SizedBox(height: 15),
                _buildPasswordField(viewModel),
                const SizedBox(height: 15),
                _buildConfirmPasswordField(viewModel),
                const SizedBox(height: 20),
                if (viewModel.hasError && viewModel.errorMessage != null)
                  _buildErrorMessage(viewModel),
                const SizedBox(height: 10),
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

  Widget _buildNameFields(SignUpViewmodel viewModel) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: viewModel.firstNameController,
            decoration: InputDecoration(
              labelText: "First Name",
              labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              prefixIcon: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
              hintText: "Ahmad",
            ),
            validator: viewModel.validateName,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            controller: viewModel.lastNameController,
            decoration: InputDecoration(
              labelText: "Last Name",
              labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              prefixIcon: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
              hintText: "Doe",
            ),
            validator: viewModel.validateName,
          ),
        ),
      ],
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
      style: TextStyle(color: Theme.of(context).primaryColor),
      decoration: InputDecoration(
        labelText: "Phone Number",
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
        hintText: "010-1234567",
      ),
      validator: viewModel.validatePhone,
    );
  }

  Widget _buildEmailField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      decoration: InputDecoration(
        labelText: "Email Address",
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        prefixIcon: Icon(Icons.mail, color: Theme.of(context).primaryColor),
        hintText: "ahmadoe@email.com",
      ),
      validator: viewModel.validateEmail,
    );
  }

  Widget _buildPasswordField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.passwordController,
      obscureText: viewModel.obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: viewModel.togglePasswordVisibility,
        ),
      ),
      validator: viewModel.validatePassword,
    );
  }

  Widget _buildConfirmPasswordField(SignUpViewmodel viewModel) {
    return TextFormField(
      controller: viewModel.confirmPasswordController,
      obscureText: viewModel.obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: "Confirm Password",
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscureConfirmPassword
                ? Icons.visibility
                : Icons.visibility_off,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: viewModel.toggleConfirmPasswordVisibility,
        ),
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
              : FilledButton(
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
            color: Colors.blueGrey,
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
