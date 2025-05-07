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

  // Constructor to setup auth state listener
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
      } else {
        return Result.error(Exception("Something went wrong"));
      }
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

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
}
