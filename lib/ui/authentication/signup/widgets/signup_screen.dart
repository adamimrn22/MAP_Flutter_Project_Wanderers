import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/signup/view_model/signup_viewmodel.dart';
import 'package:mycrochetbag/utils/result.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.viewModel});
  final SignUpViewmodel viewModel;

  @override
  State<SignUpScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ... your form
          ElevatedButton(
            onPressed: () {
              widget.viewModel.signUp((
                "Jane",
                "Doe",
                "jane@example.com",
                "12345678",
                "pass123",
              ));
            },
            child: Text("Sign Up"),
          ),
        ],
      ),
    );
  }
}
