import 'package:cloud_firestore/cloud_firestore.dart';

class Bag {
  final String id; // Firebase document ID
  final String name;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String? description;
  final int? stock;
  final List<String>? sizes;
  final String? material;
  final List<String>? colors;

  Bag({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls,
    required this.category,
    this.description,
    this.stock,
    this.sizes,
    this.material,
    this.colors,
  });

  factory Bag.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bag(
      id: doc.id,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      imageUrls: List<String>.from(data['images'] ?? []),
      category: data['category'] as String,
      description: data['description'] as String?,
      stock: data['stock'] as int?,
      sizes: (data['sizes'] as List?)?.map((e) => e as String).toList(),
      material: data['material'] as String?,
      colors: (data['colors'] as List?)?.map((e) => e as String).toList(),
    );
  }
}
