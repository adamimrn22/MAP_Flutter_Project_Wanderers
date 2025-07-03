import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycrochetbag/domain/model/Order.dart';
//import 'package:mycrochetbag/domain/model/CartItem.dart';
//import 'cart_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final FirestoreCartService _cartService = FirestoreCartService();

  Future<String> _fetchImageUrlByProductId(String productId) async {
    try {
      print('🔍 Fetching imageUrl for productId: $productId');
      final doc = await _firestore.collection('products').doc(productId).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null &&
            data['images'] != null &&
            data['images'] is List &&
            data['images'].isNotEmpty) {
          final imageUrl = data['images'][0];
          print('✅ Found imageUrl from images[0]: $imageUrl');
          return imageUrl;
        } else {
          print('⚠️ images field is missing or empty');
        }
      } else {
        print('❌ Product document does not exist');
      }
    } catch (e) {
      print('🚨 ERROR: Failed to fetch imageUrl for product $productId - $e');
    }
    return '';
  }

  // Get current user's orders
  Stream<List<OrderModel>> getUserOrders() {
    final currentUser = _auth.currentUser;
    print("Current UID: ${currentUser?.uid}");
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .doc(currentUser.uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final orders = <OrderModel>[];

          for (final doc in snapshot.docs) {
            final order = OrderModel.fromFirestore(doc);
            bool updated = false;

            for (final item in order.orders) {
              print('🧵 Checking item: ${item.name}, itemId: ${item.itemId}');
              if (item.imageUrl.isEmpty) {
                final fetchedImageUrl = await _fetchImageUrlByProductId(
                  item.itemId,
                );
                if (fetchedImageUrl.isNotEmpty) {
                  print(
                    '✅ Updating item ${item.name} with imageUrl: $fetchedImageUrl',
                  );
                  item.imageUrl = fetchedImageUrl;
                  updated = true;
                } else {
                  print('❌ No imageUrl found for itemId: ${item.itemId}');
                }
              }
            }

            if (updated) {
              // Save updated orderItems to Firestore
              await doc.reference.update({
                'orders': order.orders.map((i) => i.toMap()).toList(),
              });
              print("✅ Firestore updated with missing imageUrl");
            }

            orders.add(order);
          }

          return orders;
        });
  }

  // Get orders by status
  Stream<List<OrderModel>> getUserOrdersByStatus(String status) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  // Update order status (for admin/seller use)
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Get single order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Cancel order (if allowed)
  Future<void> cancelOrder(String orderId, String cancelReason) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelReason': cancelReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Get order statistics for user
  Future<OrderStatistics> getUserOrderStatistics() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return OrderStatistics.empty();
    }

    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('userId', isEqualTo: currentUser.uid)
              .get();

      int totalOrders = snapshot.docs.length;
      int processingOrders = 0;
      int deliveredOrders = 0;
      int cancelledOrders = 0;
      int shippedOrders = 0;
      double totalSpent = 0;

      for (final doc in snapshot.docs) {
        final order = OrderModel.fromFirestore(doc);
        totalSpent += order.amount;

        switch (order.orderStatus) {
          case OrderStatus.paid:
          case OrderStatus.pending:
            processingOrders++;
            break;

          case OrderStatus.shipped:
            shippedOrders++;
            break;

          case OrderStatus.delivered:
            deliveredOrders++;
            break;
          case OrderStatus.cancelled:
            cancelledOrders++;
            break;
        }
      }

      return OrderStatistics(
        totalOrders: totalOrders,
        processingOrders: processingOrders,
        deliveredOrders: deliveredOrders,
        cancelledOrders: cancelledOrders,
        shippedOrders: shippedOrders,
        totalSpent: totalSpent,
      );
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // Check if user can cancel order (based on status and time)
  bool canCancelOrder(OrderModel order) {
    // Can only cancel processing orders
    if (order.orderStatus != OrderStatus.paid) return false;

    // Can only cancel within 24 hours of creation (example business rule)
    final hoursSinceCreated =
        DateTime.now().difference(order.createdAt).inHours;
    return hoursSinceCreated <= 24;
  }

  // Get recent orders (last 30 days)
  Stream<List<OrderModel>> getRecentOrders() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: currentUser.uid)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }
}

// Helper class for order statistics
class OrderStatistics {
  final int totalOrders;
  final int processingOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final int shippedOrders;
  final double totalSpent;

  OrderStatistics({
    required this.totalOrders,
    required this.processingOrders,
    required this.deliveredOrders,
    required this.shippedOrders,
    required this.cancelledOrders,
    required this.totalSpent,
  });

  factory OrderStatistics.empty() {
    return OrderStatistics(
      totalOrders: 0,
      processingOrders: 0,
      shippedOrders: 0,
      deliveredOrders: 0,
      cancelledOrders: 0,
      totalSpent: 0.0,
    );
  }

  @override
  String toString() {
    return 'OrderStatistics(total: $totalOrders, processing: $processingOrders, delivered: $deliveredOrders, cancelled: $cancelledOrders, spent: RM${totalSpent.toStringAsFixed(2)})';
  }
}
