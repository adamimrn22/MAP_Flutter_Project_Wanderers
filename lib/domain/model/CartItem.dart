import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String size;
  final String color;
  final int quantity;
  final String imageUrl;
  final String category;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.size,
    required this.color,
    required this.quantity,
    required this.imageUrl,
    required this.category,
    required this.addedAt,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CartItem(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      size: data['size'] ?? '',
      color: data['color'] ?? '',
      quantity: data['quantity'] ?? 1,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'size': size,
      'color': color,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'category': category,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? size,
    String? color,
    int? quantity,
    String? imageUrl,
    String? category,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  double get totalPrice => price * quantity;

  String get cartKey => '${productId}_${size}_$color';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.productId == productId &&
        other.size == size &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(productId, size, color);

  @override
  String toString() {
    return 'CartItem(id: $id, productId: $productId, name: $name, size: $size, color: $color, quantity: $quantity)';
  }
}
