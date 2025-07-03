import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/CartItem.dart';

enum OrderStatus {
  processing,
  delivered,
  cancelled,
}

class Address {
  final String address1;
  final String address2;
  final String city;
  final String postcode;
  final String state;

  Address({
    required this.address1,
    required this.address2,
    required this.city,
    required this.postcode,
    required this.state,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      city: map['city'] ?? '',
      postcode: map['postcode'] ?? '',
      state: map['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address1': address1,
      'address2': address2,
      'city': city,
      'postcode': postcode,
      'state': state,
    };
  }
}

class OrderItemDetail {
  final String color;
  final String id;
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final String size;
  String imageUrl;

  OrderItemDetail({
    required this.color,
    required this.id,
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.size,
    required this.imageUrl,
  });

  factory OrderItemDetail.fromMap(Map<String, dynamic> map) {
    return OrderItemDetail(
      color: map['color'] ?? '',
      id: map['id'] ?? '',
      itemId: map['itemId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      size: map['size'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'id': id,
      'itemId': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'size': size,
      'imageUrl': imageUrl,
    };
  }

  // Convert from CartItem to OrderItemDetail (useful when creating orders from cart)
  factory OrderItemDetail.fromCartItem(String id, String itemId, CartItem cartItem) {
    // Debug logging to track what's being passed
    print("DEBUG: Creating OrderItemDetail from CartItem:");
    print("  - id: $id");
    print("  - itemId: $itemId");
    print("  - cartItem.name: ${cartItem.name}");
    print("  - cartItem.imageUrl: ${cartItem.imageUrl}");
    print("  - cartItem.price: ${cartItem.price}");
    print("  - cartItem.quantity: ${cartItem.quantity}");
    
    return OrderItemDetail(
      color: cartItem.color,
      id: id,
      itemId: itemId,
      name: cartItem.name,
      price: cartItem.price,
      quantity: cartItem.quantity,
      size: cartItem.size,
      imageUrl: cartItem.imageUrl, // This should capture the imageUrl from CartItem
    );
  }

  double get totalPrice => price * quantity;
}

class Payment {
  final String pspReference;
  final String resultCode;
  final String status;
  final DateTime updatedAt;

  Payment({
    required this.pspReference,
    required this.resultCode,
    required this.status,
    required this.updatedAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      pspReference: map['pspReference'] ?? '',
      resultCode: map['resultCode'] ?? '',
      status: map['status'] ?? '',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pspReference': pspReference,
      'resultCode': resultCode,
      'status': status,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class OrderModel {
  final String id;
  final Address address;
  final double amount;
  final DateTime createdAt;
  final String merchantReference;
  final List<OrderItemDetail> orderItems;
  final Payment payment;
  final DateTime updatedAt;
  final String paymentType;
  final String sellerId;
  final String status;
  final String userId;

  OrderModel({
    required this.id,
    required this.address,
    required this.amount,
    required this.createdAt,
    required this.merchantReference,
    required this.orderItems,
    required this.payment,
    required this.updatedAt,
    required this.paymentType,
    required this.sellerId,
    required this.status,
    required this.userId,
  });

  // Convert Firebase status to OrderStatus enum
  OrderStatus get orderStatus {
    switch (status.toLowerCase()) {
      case 'paid':
        return OrderStatus.processing;
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.processing;
    }
  }

  // Get display date based on status
  String get displayDate {
    if (orderStatus == OrderStatus.cancelled) {
      return 'Order cancelled by the user';
    }
    return '${createdAt.day.toString().padLeft(2, '0')} ${_getMonthName(createdAt.month)}, ${createdAt.year}';
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  // Get the main product name (first item)
  String get mainProductName {
    return orderItems.isNotEmpty ? orderItems.first.name : 'Unknown Product';
  }

  // Get the main product image URL - try to get from first product's image
  String get mainProductImageUrl {
    if (orderItems.isNotEmpty && orderItems.first.imageUrl.isNotEmpty) {
      return orderItems.first.imageUrl;
    }
    return '';
  }

  // Create OrderModel from cart items (useful when processing payment)
  factory OrderModel.fromCartCheckout({
    required String orderId,
    required Address address,
    required List<CartItem> cartItems,
    required String merchantReference,
    required Payment payment,
    required String paymentType,
    required String sellerId,
    required String userId,
  }) {
    print("DEBUG: Creating OrderModel from ${cartItems.length} cart items");
    
    double totalAmount = cartItems.fold(0, (sum, item) => sum + (item.totalPrice));
    
    List<OrderItemDetail> orderItems = cartItems.asMap().entries.map((entry) {
      int index = entry.key;
      CartItem cartItem = entry.value;    
      return OrderItemDetail.fromCartItem(
        index.toString(), 
        cartItem.productId,
        cartItem,
      );
    }).toList();

    // Log the created order items
    print("DEBUG: Created ${orderItems.length} order items:");
    for (int i = 0; i < orderItems.length; i++) {
      print("  Order item $i: name=${orderItems[i].name}, imageUrl=${orderItems[i].imageUrl}");
    }

    DateTime now = DateTime.now();
    
    return OrderModel(
      id: orderId,
      address: address,
      amount: totalAmount,
      createdAt: now,
      merchantReference: merchantReference,
      orderItems: orderItems,
      payment: payment,
      updatedAt: now,
      paymentType: paymentType,
      sellerId: sellerId,
      status: 'paid', // Initial status after payment
      userId: userId,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Debug log the Firestore data
    print("DEBUG: Loading OrderModel from Firestore doc ${doc.id}");
    if (data['orders'] != null) {
      final orders = data['orders'] as List<dynamic>;
      print("DEBUG: Found ${orders.length} order items in Firestore");
      for (int i = 0; i < orders.length; i++) {
        final item = orders[i] as Map<String, dynamic>;
        print("  Item $i: name=${item['name']}, imageUrl=${item['imageUrl'] ?? 'NULL'}");
      }
    }
    
    return OrderModel(
      id: doc.id,
      address: Address.fromMap(data['address'] ?? {}),
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate(): DateTime.now(),
      merchantReference: data['merchantReference'] ?? '',
      orderItems: (data['orders'] as List<dynamic>? ?? [])
          .map((item) => OrderItemDetail.fromMap(item as Map<String, dynamic>))
          .toList(),
      payment: Payment.fromMap(data['payment'] ?? {}),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      paymentType: data['paymentType'] ?? '',
      sellerId: data['sellerId'] ?? '',
      status: data['status'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = {
      'address': address.toMap(),
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'merchantReference': merchantReference,
      'orders': orderItems.map((item) => item.toMap()).toList(),
      'payment': payment.toMap(),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'paymentType': paymentType,
      'sellerId': sellerId,
      'status': status,
      'userId': userId,
    };
    
    // Debug log what's being saved
    print("DEBUG: Converting OrderModel to Firestore data:");
    final orders = data['orders'] as List;
    print("  Saving ${orders.length} order items:");
    for (int i = 0; i < orders.length; i++) {
      final item = orders[i] as Map<String, dynamic>;
      print("    Item $i: name=${item['name']}, imageUrl=${item['imageUrl']}");
    }
    
    return data;
  }
}