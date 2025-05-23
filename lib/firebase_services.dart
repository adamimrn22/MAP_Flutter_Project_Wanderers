import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart'; 

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _firestore.collection('products').doc(productId).update(data);
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}
