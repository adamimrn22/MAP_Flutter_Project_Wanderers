// lib/ui/seller/seller_manage_customer_order/model/order.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Defines the product model included in an order
class OrderProduct {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl; // Product image URL

  OrderProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productId: json['productId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}

// Defines the order data model
class Order {
  final String id; // Firestore document ID
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String sellerId; // Associated seller ID
  final double totalAmount;
  final DateTime orderDate;
  final String status; // e.g., 'pending', 'shipped', 'delivered', 'cancelled'
  final Map<String, dynamic>
  shippingAddress; // Map containing address information
  final List<OrderProduct> products; // List of products in the order

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.sellerId,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.shippingAddress,
    required this.products,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<OrderProduct> productsList = [];
    if (data['products'] != null) {
      productsList =
          (data['products'] as List)
              .map(
                (item) => OrderProduct.fromJson(item as Map<String, dynamic>),
              )
              .toList();
    }

    return Order(
      id: doc.id,
      customerId: data['customerId'] as String,
      customerName: data['customerName'] as String? ?? 'Unknown Customer',
      customerEmail: data['customerEmail'] as String? ?? 'N/A',
      sellerId: data['sellerId'] as String,
      totalAmount: (data['totalAmount'] as num).toDouble(),
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      status: data['status'] as String,
      shippingAddress: Map<String, dynamic>.from(data['shippingAddress'] ?? {}),
      products: productsList,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'sellerId': sellerId,
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
      'shippingAddress': shippingAddress,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}
