// lib/ui/seller/seller_manage_customer_order/view_model/seller_order_list_view_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    as firestore; // Use prefix for firestore to avoid naming conflicts
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/model/order.dart'; // Import your custom Order model

class SellerOrderListViewModel extends ChangeNotifier {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance; // Use prefixed Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Order> _allOrders = []; // Stores all orders for the current seller
  List<Order> _filteredOrders = []; // Stores filtered and sorted orders

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSellerUid; // Current logged-in seller's UID

  // For filtering order status, e.g.: 'All', 'Pending', 'Shipped', 'Delivered'
  String _selectedStatusFilter = 'All';

  SellerOrderListViewModel() {
    _initAndFetchOrders();
  }

  // Getters for UI
  List<Order> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatusFilter => _selectedStatusFilter;

  // Setter for UI to update filter and trigger refresh
  void setSelectedStatusFilter(String status) {
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
      _currentSellerUid = user.uid;

      await _fetchOrdersFromFirestore();
      _applyFilters(); // Apply initial filter
    } catch (e) {
      _errorMessage = "Error initializing or fetching orders: $e";
      print("❌ Error in SellerOrderListViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchOrdersFromFirestore() async {
    if (_currentSellerUid == null) {
      _errorMessage = "Seller UID not available.";
      return;
    }

    try {
      // Get orders for the current seller from the 'orders' collection in Firestore
      // Assumes order documents have a 'sellerId' field
      final querySnapshot =
          await _firestore
              .collection('orders')
              .where('sellerId', isEqualTo: _currentSellerUid)
              .orderBy(
                'orderDate',
                descending: true,
              ) // Order by date descending
              .get();

      // Ensure that 'Order.fromFirestore' correctly handles potential null values from Firestore
      _allOrders =
          querySnapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } catch (e) {
      _errorMessage = "Error fetching orders from Firestore: $e";
      print("❌ Error fetching orders from Firestore: $e");
      _allOrders = []; // Clear data on error
    }
  }

  void _applyFilters() {
    List<Order> tempOrders = List.from(
      _allOrders,
    ); // List.from will correctly copy the list of Order objects

    // Filter by order status
    if (_selectedStatusFilter != 'All') {
      tempOrders =
          tempOrders
              .where(
                (order) => order.status == _selectedStatusFilter.toLowerCase(),
              )
              .toList();
    }

    _filteredOrders = tempOrders;
    notifyListeners();
  }

  // Public method to refresh the list, e.g., after updating order status or returning from detail page
  Future<void> refreshOrders() async {
    await _initAndFetchOrders();
  }
}
