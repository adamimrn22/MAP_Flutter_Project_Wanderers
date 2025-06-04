import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycrochetbag/data/services/bag_service.dart';

class SellerAddBagViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  List<XFile> images = [];
  String? productName;
  double? price;
  int? stock;
  List<String> selectedSizes = [];
  String? selectedCategory;
  String? selectedMaterial;
  String? description;
  List<String> colors = [];

  final List<String> sizes = ['S', 'M', 'L'];
  final List<String> bagCategories = ['Tote', 'Sling', 'Backpack'];
  final List<String> materials = ['Cotton', 'Wool', 'Canvas'];

  Future<void> pickImages() async {
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      images = pickedFiles;
      notifyListeners();
    }
  }

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
    notifyListeners();
  }

  Future<String?> saveProduct(BuildContext context) async {
    if (!formKey.currentState!.validate()) return null;

    if (images.isEmpty) return 'Please select at least one image';
    if (selectedSizes.isEmpty) return 'Please select at least one size';

    formKey.currentState!.save();

    try {
      await FirestoreBagServices().addProduct(
        imageFiles: images.map((xfile) => File(xfile.path)).toList(),
        name: productName!,
        price: price!,
        stock: stock!,
        sizes: selectedSizes,
        category: selectedCategory!,
        material: selectedMaterial!,
        description: description!,
        colors: colors,
      );
      return null; // success
    } catch (e) {
      return 'Failed to add product: $e';
    }
  }
}
