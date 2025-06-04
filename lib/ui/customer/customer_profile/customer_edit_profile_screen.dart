import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/ui/core/themes/themes.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/view_model/customer_edit_profile_view_model.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  _CustomerEditProfileScreenState createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServices>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(authService),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: RoseBlushColors.background,
        body: Consumer<EditProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _EditProfileForm(viewModel: viewModel);
          },
        ),
      ),
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  final EditProfileViewModel viewModel;

  const _EditProfileForm({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: viewModel.isLoading ? null : () => viewModel.pickImage(),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                  child:
                      viewModel.profileImage != null
                          ? ClipOval(
                            child: Image.file(
                              File(viewModel.profileImage!.path),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                          : viewModel.profilePictureUrl != null &&
                              viewModel.profilePictureUrl!.isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              '${viewModel.profilePictureUrl}?${DateTime.now().millisecondsSinceEpoch}',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  '❌ Error loading profile picture: $error',
                                );
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                          : const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to change profile picture',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 24),

            // First Name Field
            TextFormField(
              initialValue: viewModel.firstName ?? '',
              decoration: const InputDecoration(labelText: 'First Name'),
              onSaved: (val) => viewModel.firstName = val,
              validator: (val) => val!.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            // Last Name Field
            TextFormField(
              initialValue: viewModel.lastName ?? '',
              decoration: const InputDecoration(labelText: 'Last Name'),
              onSaved: (val) => viewModel.lastName = val,
              validator: (val) => val!.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            // Phone Number Field
            TextFormField(
              initialValue: viewModel.phoneNumber ?? '',
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              onSaved: (val) => viewModel.phoneNumber = val,
              validator: (val) => val!.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed:
                  viewModel.isLoading
                      ? null
                      : () async {
                        final result = await viewModel.saveProfile(context);
                        if (result == null) {
                          context.pop(); // Navigate back to profile screen
                        }
                      },
              child:
                  viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
