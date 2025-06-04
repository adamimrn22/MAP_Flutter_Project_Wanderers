import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload image and get URL using Supabase
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> imageUrls = [];

    for (var imageFile in imageFiles) {
      try {
        final url = await SupabaseService().uploadImage(imageFile);
        imageUrls.add(url);
      } catch (e, stackTrace) {
        print("❌ Supabase Upload failed: $e\n📍 StackTrace: $stackTrace");
        rethrow;
      }
    }

    return imageUrls;
  }

  // Add Product (store in Firestore)
  Future<void> addProduct({
    required List<File> imageFiles,
    required String name,
    required double price,
    required int stock,
    required List<String> sizes,
    required String category,
    required String material,
    required String description,
    required List<String> colors,
  }) async {
    try {
      final imageUrls = await uploadImages(imageFiles);

      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'stock': stock,
        'sizes': sizes,
        'category': category,
        'material': material,
        'description': description,
        'colors': colors,
        'images': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Product added successfully");
    } catch (e, stackTrace) {
      print("❌ Error in addProduct: $e\n📍 StackTrace: $stackTrace");
      rethrow;
    }
  }

  // Read all products
  Stream<QuerySnapshot> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update product by ID
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('products').doc(productId).update(data);
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      // Step 1: Fetch product doc
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception("Product not found");

      final productData = doc.data()!;
      print("🔍 productData: $productData");
      final List<dynamic> imageUrls = productData['images'] ?? [];
      print("🖼️ imageUrls to delete: $imageUrls");

      // Step 2: Delete images from Supabase
      for (String imageUrl in imageUrls) {
        final path = _extractPathFromUrl(imageUrl);

        if (path != null) {
          print("🗑️ Deleting: $path");
          final res = await _supabase.storage.from('product-images').remove([
            path,
          ]);
          print("📦 Supabase delete result: $res");
        } else {
          print("⚠️ Could not extract path from: $imageUrl");
        }
      }

      // Step 3: Delete document
      await _firestore.collection('products').doc(productId).delete();
      print("✅ Firestore product deleted");
    } catch (e) {
      rethrow;
    }
  }

  // Helper: Extract image path from Supabase URL
  String? _extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      final bucketIndex = segments.indexOf('object');
      if (bucketIndex == -1 || segments.length < bucketIndex + 3) return null;

      // Skip the public, bucket-name, and return path inside the bucket
      return segments.sublist(bucketIndex + 3).join('/');
    } catch (e) {
      print("⚠️ Error extracting path from URL: $e");
      return null;
    }
  }

  // NEW: Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        print("⚠️ User document not found for userId: $userId");
        return null;
      }
      print("✅ User data retrieved: ${doc.data()}");
      return doc.data();
    } catch (e, stackTrace) {
      print("❌ Error fetching user data: $e\n📍 StackTrace: $stackTrace");
      rethrow;
    }
  }

  Future<String?> uploadProfilePicture(File image, String userId) async {
    try {
      final fileName = 'profile_$userId.png';
      final filePath = 'profile_pictures/$fileName';

      // Check if the file already exists and delete it to allow overwrite
      try {
        await _supabase.storage.from('product-images').getPublicUrl(filePath);
        // If the above doesn't throw an error, the file exists; delete it
        await _supabase.storage.from('product-images').remove([filePath]);
        print("🗑️ Existing profile picture deleted: $filePath");
      } catch (e) {
        // File doesn't exist, proceed with upload
        print("ℹ️ No existing profile picture found at $filePath");
      }

      // Upload the new profile picture
      final storageResponse = await _supabase.storage
          .from('product-images')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(upsert: true),
          );

      if (storageResponse.isEmpty) {
        throw Exception('Profile picture upload failed.');
      }

      // Get the public URL
      final publicUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(filePath);

      print("✅ Profile picture uploaded: $publicUrl");
      return publicUrl;
    } catch (e, stackTrace) {
      print(
        "❌ Error uploading profile picture: $e\n📍 StackTrace: $stackTrace",
      );
      rethrow;
    }
  }

  // In firebase_services.dart, replace or add this method
  Future<void> updateUserProfile(
    String userId, {
    required String userName,
    required String profilePictureUrl,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final data = {
        'name': userName,
        'profilePictureUrl': profilePictureUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };
      await _firestore
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
      print("✅ User profile updated for userId: $userId");
    } catch (e, stackTrace) {
      print("❌ Error updating user profile: $e\n📍 StackTrace: $stackTrace");
      rethrow;
    }
  }
}
