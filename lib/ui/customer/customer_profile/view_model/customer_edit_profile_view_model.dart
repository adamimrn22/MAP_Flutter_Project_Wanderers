import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycrochetbag/data/services/bag_service.dart'; // Assuming this handles Firestore operations
import 'package:mycrochetbag/data/services/auth_service.dart'; // For accessing current user

class EditProfileViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final AuthServices authService;

  XFile? profileImage;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? profilePictureUrl; // Current profile picture URL from Firestore
  bool isLoading = false;

  EditProfileViewModel(this.authService) {
    _loadUserData();
  }

  // Load current user data from Firestore
  Future<void> _loadUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      final userData = await FirestoreBagServices().getUserData(
        authService.currentUser!.uid,
      );
      firstName = userData?['firstName'] ?? '';
      lastName = userData?['lastName'] ?? '';
      phoneNumber = userData?['phoneNumber'] ?? '';
      profilePictureUrl = userData?['profilePictureUrl'] ?? '';
    } catch (e) {
      print('Error loading user data: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // Pick a new profile image
  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      profileImage = pickedFile;
      notifyListeners();
    }
  }

  // Save updated profile data
  Future<String?> saveProfile(BuildContext context) async {
    if (!formKey.currentState!.validate())
      return 'Please fill all required fields';

    formKey.currentState!.save();

    try {
      isLoading = true;
      notifyListeners();

      String? newProfilePictureUrl = profilePictureUrl;
      if (profileImage != null) {
        // Upload new profile picture to Supabase
        newProfilePictureUrl = await FirestoreBagServices()
            .uploadProfilePicture(
              File(profileImage!.path),
              authService.currentUser!.uid,
            );
      }

      // Update user data in Firestore
      await FirestoreBagServices().updateUserProfile(
        authService.currentUser!.uid,
        userName: '$firstName $lastName', // Combine for backward compatibility
        profilePictureUrl: newProfilePictureUrl ?? '',
        firstName: firstName!,
        lastName: lastName!,
        phoneNumber: phoneNumber!,
      );

      return null; // Success
    } catch (e) {
      return 'Failed to update profile: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
