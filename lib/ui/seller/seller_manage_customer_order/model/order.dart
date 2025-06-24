// lib/ui/seller/seller_manage_customer_order/model/order.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for order status
enum OrderStatus {
  pending, // Corresponds to 'pending'
  processing, // Corresponds to 'processing'
  shipped, // Corresponds to 'shipped'
  delivered, // Corresponds to 'delivered'
  cancelled, // Corresponds to 'cancelled'
  paid, // Corresponds to 'paid' (from payment status)
  // Add other statuses if needed
}

// Extension to convert String to OrderStatus
extension OrderStatusExtension on String {
  OrderStatus toOrderStatus() {
    switch (this.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'paid':
        return OrderStatus.paid;
      default:
        return OrderStatus.pending; // Default to pending if unknown
    }
  }
}

// Defines the product model included in an order, based on Firestore 'orders' array item
// 根据 Firestore 中的 'orders' 数组项定义订单中包含的商品模型
class OrderProduct {
  final String
  id; // This seems to be the document ID for the product instance in the cart/order
  final String
  itemId; // This looks like the actual product ID from your bags collection
  final String color;
  final String name; // Now directly available in the nested order item
  final double price; // Now directly available in the nested order item
  final int quantity; // Now directly available in the nested order item
  final String?
  size; // Now directly available in the nested order item (optional)
  final String?
  imageUrl; // Assuming this will be fetched or added later if not present

  OrderProduct({
    required this.id,
    required this.itemId,
    required this.color,
    required this.name,
    required this.price,
    required this.quantity,
    this.size,
    this.imageUrl, // Keep it nullable
  });

  // Factory constructor to create OrderProduct from a Firestore map item in the 'orders' array
  // 从 Firestore 'orders' 数组中的 Map 项创建 OrderProduct 的工厂构造函数
  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      color: json['color'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      size: json['size'] as String?, // size is now explicitly in your data
      imageUrl:
          json['imageUrl']
              as String?, // If imageUrl is added to order items, get it here
    );
  }

  // Method to convert OrderProduct to a Firestore map (for saving)
  // 将 OrderProduct 转换为 Firestore Map 的方法（用于保存）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'color': color,
      'name': name,
      'price': price,
      'quantity': quantity,
      'size': size,
      'imageUrl': imageUrl,
    };
  }
}

// Defines the main order data model, matching your Firestore document structure
// 定义主订单数据模型，匹配您的 Firestore 文档结构
class Order {
  final String id; // Firestore document ID
  final Map<String, dynamic> address; // Contains address details
  final double amount; // Total amount of the order
  final DateTime createdAt; // Order creation timestamp
  final String merchantReference; // Reference to the merchant/seller
  final List<OrderProduct>
  products; // List of items in this specific order (from the 'orders' array in Firestore)
  final Map<String, dynamic> payment; // Payment details
  final String userId; // User who placed the order
  OrderStatus status; // Top-level status field (now using enum)

  Order({
    required this.id,
    required this.address,
    required this.amount,
    required this.createdAt,
    required this.merchantReference,
    required this.products,
    required this.payment,
    required this.userId,
    required this.status, // Now required as it's directly from Firestore
  });

  // Factory constructor to create an Order from a Firestore DocumentSnapshot
  // 从 Firestore DocumentSnapshot 创建 Order 的工厂构造函数
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<OrderProduct> productsList = [];
    if (data['orders'] != null && data['orders'] is List) {
      // Note: 'orders' is the field name from your screenshot
      productsList =
          (data['orders'] as List)
              .map(
                (item) => OrderProduct.fromJson(item as Map<String, dynamic>),
              )
              .toList();
    }

    return Order(
      id: doc.id,
      address: Map<String, dynamic>.from(data['address'] ?? {}),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          (data['createdAt'] is Timestamp)
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(), // Fallback to current time
      merchantReference: data['merchantReference'] as String? ?? 'N/A',
      products: productsList,
      payment: Map<String, dynamic>.from(
        data['payment'] ?? {},
      ), // Get payment map
      userId: data['userId'] as String, // Get userId
      status:
          (data['status'] as String? ?? 'pending')
              .toOrderStatus(), // Convert string to enum
    );
  }

  // Method to convert Order to a Firestore map (for saving or updating)
  // 将 Order 转换为 Firestore Map 的方法（用于保存或更新）
  Map<String, dynamic> toFirestore() {
    return {
      'address': address,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'merchantReference': merchantReference,
      'orders':
          products.map((p) => p.toJson()).toList(), // Note: 'orders' field name
      'payment': payment,
      'userId': userId,
      'status': status.name, // Convert enum to string for Firestore
    };
  }
}
