import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/domain/model/Address.dart';
import 'package:mycrochetbag/domain/model/OrderItem.dart';
import 'package:mycrochetbag/domain/model/Payment.dart';

class CustomerOrder {
  final String id;
  final Address address;
  final double amount;
  final DateTime createdAt;
  final String merchantReference;
  final List<OrderItem> orders;
  final Payment payment;
  final String paymentType;
  final String status;
  final DateTime updatedAt;
  final String userId;
  final String? trackingId;
  final String? cancelReason;

  CustomerOrder({
    required this.id,
    required this.address,
    required this.amount,
    required this.createdAt,
    required this.merchantReference,
    required this.orders,
    required this.payment,
    required this.paymentType,
    required this.status,
    required this.updatedAt,
    required this.userId,
    this.trackingId,
    this.cancelReason,
  });

  factory CustomerOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      return (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    }

    return CustomerOrder(
      id: doc.id,
      address: Address.fromMap(data['address'] ?? {}),
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: parseTimestamp(data['createdAt']),
      merchantReference: data['merchantReference'] ?? '',
      orders:
          (data['orders'] as List? ?? [])
              .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList(),
      payment: Payment.fromMap(data['payment'] ?? {}),
      paymentType: data['paymentType'] ?? '',
      status: data['status'] ?? 'pending',
      updatedAt: parseTimestamp(data['updatedAt']),
      userId: data['userId'] ?? '',
      trackingId: data['trackingId'] as String?, // nullable
      cancelReason: data['cancelReason'] as String?, // nullable
    );
  }

  OrderStatus get orderStatus {
    switch (status.toLowerCase()) {
      case 'paid':
        return OrderStatus.paid;
      case 'ship':
        return OrderStatus.shipped;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'delivered':
        return OrderStatus.delivered;
      default:
        return OrderStatus.paid;
    }
  }

  @override
  String toString() {
    return '''
      CustomerOrder(
        id: $id,
        userId: $userId,
        status: $status,
        paymentType: $paymentType,
        merchantReference: $merchantReference,
        amount: $amount,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
        address: ${address.fullAddress},
        orders: ${orders.map((o) => o.toString()).join(', ')},
        payment: $payment
      )
      ''';
  }
}

enum OrderStatus { pending, paid, shipped, delivered, cancelled }
