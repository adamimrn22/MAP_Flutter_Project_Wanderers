import 'package:flutter/material.dart';
import 'package:mycrochetbag/domain/model/Order.dart';
import 'package:mycrochetbag/data/services/customer_order_service.dart';

class CustomerOrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = true;
  String? _error;
  OrderStatus? _currentFilter;
  OrderStatistics? _orderStatistics;

  // Getters
  List<OrderModel> get allOrders => _allOrders;
  List<OrderModel> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderStatus? get currentFilter => _currentFilter;
  OrderStatistics? get orderStatistics => _orderStatistics;

  // Initialize and load orders
  void init() {
    loadOrders();
    //loadOrderStatistics();
  }

  // Load all orders from Firestore
  void loadOrders() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _orderService.getUserOrders().listen(
      (orders) {
        _allOrders = orders;
        _applyFilter();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Filter orders by status
  void filterOrders(OrderStatus? status) {
    _currentFilter = status;
    print('status: ${status}');
    _applyFilter();
    notifyListeners();
  }

  // Apply current filter to orders
  void _applyFilter() {
    if (_currentFilter == null) {
      _filteredOrders = List.from(_allOrders);
    } else {
      _filteredOrders =
          _allOrders
              .where((order) => order.orderStatus == _currentFilter)
              .toList();
    }
  }

  // Get orders count by status
  int getOrdersCountByStatus(OrderStatus status) {
    return _allOrders.where((order) => order.orderStatus == status).length;
  }

  // Get total orders count
  int get totalOrdersCount => _allOrders.length;

  // Cancel an order
  Future<void> cancelOrder(String orderId, String userId) async {
    try {
      String orderDoc = '${userId}/orders/${orderId}';
      await _orderService.cancelOrder(orderDoc, 'Cancelled By User');
    } catch (e) {
      _error = e.toString();
      print(e);
      notifyListeners();
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    loadOrders();
    //loadOrderStatistics();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
