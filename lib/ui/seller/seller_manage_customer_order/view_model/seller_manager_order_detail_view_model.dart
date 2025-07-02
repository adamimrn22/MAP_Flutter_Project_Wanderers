import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mycrochetbag/data/services/manage_order_service.dart';
import 'package:mycrochetbag/data/services/manage_user_service.dart';
import 'package:mycrochetbag/domain/model/Address.dart';
import 'package:mycrochetbag/domain/model/CustomerOrder.dart';
import 'package:mycrochetbag/domain/model/User.dart';

class SellerManageOrderDetailViewModel extends ChangeNotifier {
  // Private fields
  bool _isLoading = false;
  String? _error;
  CustomerOrder? _order;
  User? _user;
  Address? _address;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  CustomerOrder? get order => _order;
  User? get user => _user;
  Address? get address => _address;

  // Load order details
  Future<void> loadOrders(String userId, String orderId) async {
    _setLoading(true);
    _setError(null);

    try {
      final orders = await ManageOrderService.getCustomerOrdersDetails(
        "/orders/$userId/orders/$orderId",
      );

      final user = await ManageUserService.fetchUserById(orders.first.userId);

      _order = orders.isNotEmpty ? orders.first : null;
      _user = user;
      _address = _order?.address;

      print(_order);
      print(_user);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update order status
  Future<void> updateOrderStatus({
    required String status,
    String? trackingNumber,
    String? cancelReason,
  }) async {
    final userId = _order!.userId;
    final orderId = _order!.id;

    final docRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(userId)
        .collection('orders')
        .doc(orderId);

    // Build data map
    final Map<String, dynamic> dataToUpdate = {
      'status': status,
      'updatedAt':
          FieldValue.serverTimestamp(), // optional: for tracking updates
    };

    if (status == 'shipped' && trackingNumber != null) {
      dataToUpdate['trackingNumber'] = trackingNumber;
    }

    if (status == 'cancelled' && cancelReason != null) {
      dataToUpdate['cancelReason'] = cancelReason;
    }

    try {
      await docRef.update(dataToUpdate);
      print('Order updated successfully.');
    } catch (e) {
      print('Error updating order: $e');
      // Handle error (e.g., show snackbar or log to error service)
    }

    // Optionally reload order details
    await loadOrders(userId, orderId);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Utility methods for UI
  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'paid':
        return 'orange';
      case 'shipped':
        return 'blue';
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  String getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'paid':
        return 'access_time';
      case 'shipped':
        return 'local_shipping';
      case 'delivered':
        return 'check_circle';
      case 'cancelled':
        return 'cancel';
      default:
        return 'info';
    }
  }

  bool shouldShowUpdateButton() {
    return _order?.status == 'paid' || _order?.status == 'shipped';
  }

  bool shouldShowShippingInfo() {
    return _order?.status == 'shipped' || _order?.status == 'completed';
  }

  bool shouldShowCancelInfo() {
    return _order?.status == 'cancelled';
  }

  bool isDeliveredEnabled() {
    return _order?.status.toLowerCase() == 'shipped';
  }
}
