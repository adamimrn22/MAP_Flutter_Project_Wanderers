import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/repositories/auth/auth_repository.dart';
import 'package:mycrochetbag/utils/result.dart';

class AuthServices extends ChangeNotifier implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  AuthServices() {
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> customerSignUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': "customer",
      });
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return Result.error(Exception(e.toString()));
      } else if (e.code == 'weak-password') {
        return Result.error(Exception(e.toString()));
      } else {
        return Result.error(Exception("Something went wrong"));
      }
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  Stream<bool> get isAuthenticatedStream {
    return FirebaseAuth.instance.authStateChanges().map((user) => user != null);
  }

  @override
  Future<String?> getUserRole() async {
    final user = currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return doc.get('role') as String?;
        }
      } catch (e) {
        print('Error getting user role: $e');
      }
    }
    return null;
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(Exception(e.message ?? 'Failed to send reset email'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  Future<Result<String>> verifyPasswordResetCode({
    required String oobCode,
  }) async {
    try {
      final email = await _auth.verifyPasswordResetCode(oobCode);
      return Result.ok(email);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        Exception(e.message ?? 'Invalid or expired reset code'),
      );
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> confirmPasswordReset({
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      await _auth.confirmPasswordReset(code: oobCode, newPassword: newPassword);
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(Exception(e.message ?? 'Failed to reset password'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(Exception('No user is currently signed in'));
      }

      // Reauthenticate the user with their old password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(newPassword);
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Incorrect old password';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please sign in again to change your password';
          break;
        default:
          errorMessage = e.message ?? 'Failed to change password';
      }
      return Result.error(Exception(errorMessage));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }
}
