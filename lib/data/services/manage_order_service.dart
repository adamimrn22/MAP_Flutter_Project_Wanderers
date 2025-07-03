import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/domain/model/CustomerOrder.dart';

class ManageOrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';

  // Get all orders for a specific user
  static Future<List<CustomerOrder>> getAllOrders() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collectionGroup(_ordersCollection)
              .where('status', isNotEqualTo: "pending")
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => CustomerOrder.fromFirestore(doc))
          .toList();
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get orders by status
  static Future<List<CustomerOrder>> getOrdersByStatus(String status) async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collectionGroup(_ordersCollection)
              .where('status', isEqualTo: status)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => CustomerOrder.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }

  // Get orders by multiple statuses (for shipped tab - paid orders)
  static Future<List<CustomerOrder>> getOrdersByStatuses(
    List<String> statuses,
  ) async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collection(_ordersCollection)
              .where('status', whereIn: statuses)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => CustomerOrder.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by statuses: $e');
    }
  }

  static Future<List<CustomerOrder>> getCustomerOrdersDetails(String id) async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collectionGroup(_ordersCollection)
              .where(FieldPath.documentId, isEqualTo: id)
              .get();

      return querySnapshot.docs
          .map((doc) => CustomerOrder.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("$e");
      throw Exception('Failed to fetch orders by statuses: $e');
    }
  }

  // Get real-time orders stream
  static Stream<List<CustomerOrder>> getOrdersStream() {
    return _firestore
        .collection(_ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CustomerOrder.fromFirestore(doc))
                  .toList(),
        );
  }

  // Update order status
  static Future<void> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
