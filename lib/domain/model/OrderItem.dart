class OrderItem {
  final String color;
  final String id;
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final String size;

  OrderItem({
    required this.color,
    required this.id,
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.size,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      color: map['color'] ?? '',
      id: map['id'] ?? '',
      itemId: map['itemId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      size: map['size'] ?? '',
    );
  }

  @override
  String toString() {
    return 'OrderItem('
        'id: $id, '
        'itemId: $itemId, '
        'name: $name, '
        'color: $color, '
        'size: $size, '
        'quantity: $quantity, '
        'price: $price'
        ')';
  }
}
