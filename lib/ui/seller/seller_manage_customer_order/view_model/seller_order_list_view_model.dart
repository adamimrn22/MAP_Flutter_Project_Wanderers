// lib/ui/seller/seller_manage_customer_order/view_model/seller_order_list_view_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/model/order.dart'; // Import Order model and OrderStatus enum
import 'dart:async'; // Import for StreamSubscription

class SellerOrderListViewModel extends ChangeNotifier {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSellerUid; // Current logged-in seller's UID

  // Changed to use OrderStatus enum for filter
  OrderStatus? _selectedStatusFilter; // Null for 'All'

  StreamSubscription<firestore.QuerySnapshot>?
  _orderSubscription; // StreamSubscription to manage the listener

  SellerOrderListViewModel() {
    _initAndFetchOrders();
  }

  // Getters for UI
  List<Order> get allOrders => _allOrders; // This is the new public getter
  List<Order> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderStatus? get selectedStatusFilter => _selectedStatusFilter;

  // Setter for UI to update filter and trigger refresh
  void setSelectedStatusFilter(OrderStatus? status) {
    _selectedStatusFilter = status;
    _applyFilters();
  }

  Future<void> _initAndFetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No seller is logged in.");
      }
      _currentSellerUid =
          user.uid; // Get the current logged-in user's UID (which should be the seller's UID)

      // Dispose of any previous subscription before starting a new one
      _orderSubscription?.cancel();
      _startOrderListener(); // Start the real-time listener
    } catch (e) {
      _errorMessage = "Error initializing or fetching orders: $e";
      print("❌ Error in SellerOrderListViewModel: $e");
    } finally {
      _isLoading =
          false; // Initial loading state is resolved after listener setup
      notifyListeners();
    }
  }

  void _startOrderListener() {
    if (_currentSellerUid == null) {
      _errorMessage = "Seller UID not available, cannot start listener.";
      notifyListeners();
      return;
    }

    // Query for orders.
    // IMPORTANT: This query assumes that your 'orders' documents have a 'sellerId' field
    // at the top level, which directly stores the UID of the seller for that order.
    // If this field does not exist in your Firestore 'orders' collection for existing or new orders,
    // this query will return no results.
    // You MUST ensure 'sellerId' is added to the order document during the order creation process.
    // If 'merchantReference' indeed starts with the sellerId, the old query using range would work.
    // However, given the structure, 'sellerId' as a dedicated field is ideal.
    _orderSubscription = _firestore
        .collection('orders')
        .where(
          'sellerId',
          isEqualTo: _currentSellerUid!,
        ) // <--- Assuming 'sellerId' field now exists
        .orderBy(
          'createdAt',
          descending: true,
        ) // Order by creation date descending
        .snapshots() // Use snapshots() for real-time updates
        .listen(
          (querySnapshot) {
            _allOrders =
                querySnapshot.docs
                    .map((doc) => Order.fromFirestore(doc))
                    .toList();
            _applyFilters(); // Apply filters whenever data changes
            _isLoading = false; // Ensure loading is off after first data fetch
            _errorMessage =
                null; // Clear any previous errors on successful data fetch
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = "Error listening to orders: $error";
            _isLoading = false;
            print("❌ Error listening to orders: $error");
            notifyListeners();
          },
        );
  }

  void _applyFilters() {
    List<Order> tempOrders = List.from(_allOrders);

    if (_selectedStatusFilter != null) {
      // Filter if a specific status is selected
      tempOrders =
          tempOrders
              .where((order) => order.status == _selectedStatusFilter)
              .toList();
    }

    _filteredOrders = tempOrders;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _orderSubscription?.cancel(); // Cancel current listener
    _startOrderListener(); // Restart listener
  }

  @override
  void dispose() {
    _orderSubscription
        ?.cancel(); // Cancel the subscription when the ViewModel is disposed
    super.dispose();
  }
}
