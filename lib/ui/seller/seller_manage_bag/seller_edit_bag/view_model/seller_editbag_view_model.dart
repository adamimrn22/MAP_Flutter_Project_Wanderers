import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerEditBagViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Product data
  final String productId;
  String? productName;
  double? price;
  int? stock;
  String? selectedCategory;
  String? selectedMaterial;
  String? description;
  List<String> colors = [];
  List<String> selectedSizes = [];
  
  // Images
  List<String> existingImageUrls = [];
  List<XFile> newImages = [];
  List<String> imagesToDelete = []; // Track images to be deleted from Supabase
  
  // Loading state
  bool isLoading = false;
  
  // Static data - same as add form
  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];
  final List<String> bagCategories = [
    'Tote',
    'Sling',
    'Backpack',
  ];
  final List<String> materials = ['Cotton', 'Wool', 'Canvas'];

  SellerEditBagViewModel(Map<String, dynamic> productData, this.productId) {
    _initializeWithProductData(productData);
  }

  void _initializeWithProductData(Map<String, dynamic> data) {
      print('Product data: $data'); // Add this line for debugging
      print('Category from data: ${data['category']}'); // Debug category
      print('Material from data: ${data['material']}'); // Debug material
    productName = data['name'] ?? '';
    price = (data['price'] as num?)?.toDouble();
    stock = data['stock'] ?? 0;
    
    // Safely set dropdown values - only if they exist in the predefined lists
    final categoryFromData = data['category'];
    selectedCategory = bagCategories.contains(categoryFromData) ? categoryFromData : null;
    
    final materialFromData = data['material'];
    selectedMaterial = materials.contains(materialFromData) ? materialFromData : null;
    
    description = data['description'] ?? '';
    
    // Handle colors - could be List<String> or String
    if (data['colors'] is List) {
      colors = List<String>.from(data['colors']);
    } else if (data['colors'] is String && data['colors'].isNotEmpty) {
      colors = (data['colors'] as String).split(',').map((e) => e.trim()).toList();
    } else {
      colors = [];
    }
    
    // Handle sizes - only include valid sizes
    if (data['sizes'] is List) {
      final sizesFromData = List<String>.from(data['sizes']);
      selectedSizes = sizesFromData.where((size) => sizes.contains(size)).toList();
    }
    
    // Handle existing images
    if (data['images'] is List) {
      existingImageUrls = List<String>.from(data['images']);
    }
  }

  bool get hasImages => existingImageUrls.isNotEmpty || newImages.isNotEmpty;

  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      newImages.addAll(pickedFiles);
      notifyListeners();
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void removeExistingImage(String imageUrl) {
    existingImageUrls.remove(imageUrl);
    imagesToDelete.add(imageUrl);
    notifyListeners();
  }

  void removeNewImage(XFile image) {
    newImages.remove(image);
    notifyListeners();
  }

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
    notifyListeners();
  }

  Future<String?> updateProduct(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return 'Please fill in all required fields';
    }

    if (!hasImages) {
      return 'Please select at least one image';
    }

    if (selectedSizes.isEmpty) {
      return 'Please select at least one size';
    }

    formKey.currentState!.save();
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload new images to Supabase
      List<String> newImageUrls = [];
      for (XFile image in newImages) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final filePath = 'products/${user.uid}/$fileName';
        
        final file = File(image.path);
        final response = await Supabase.instance.client.storage
            .from('product-images')
            .upload(filePath, file);

        if (response.isNotEmpty) {
          final imageUrl = Supabase.instance.client.storage
              .from('product-images')
              .getPublicUrl(filePath);
          newImageUrls.add(imageUrl);
        }
      }

      // Delete removed images from Supabase
      for (String imageUrl in imagesToDelete) {
        try {
          // Extract file path from URL
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          final filePath = pathSegments.sublist(pathSegments.indexOf('product-images') + 1).join('/');
          
          await Supabase.instance.client.storage
              .from('product-images')
              .remove([filePath]);
        } catch (e) {
          debugPrint('Error deleting image: $e');
        }
      }

      // Combine existing and new image URLs
      final allImageUrls = [...existingImageUrls, ...newImageUrls];

      // Update product in Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'name': productName,
        'price': price,
        'stock': stock,
        'category': selectedCategory,
        'material': selectedMaterial,
        'description': description,
        'colors': colors,
        'sizes': selectedSizes,
        'images': allImageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
      
    } catch (e) {
      debugPrint('Error updating product: $e');
      return 'Failed to update product: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}