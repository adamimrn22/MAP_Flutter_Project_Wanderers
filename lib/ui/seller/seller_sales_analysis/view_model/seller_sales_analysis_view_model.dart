import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mycrochetbag/data/services/sales_analysis_service.dart';
import 'package:mycrochetbag/domain/model/CustomerOrder.dart';

class SalesAnalysisViewModel extends ChangeNotifier {
  // Analytics data
  Map<String, dynamic> _analyticsData = {};
  List<Map<String, dynamic>> _monthlyData = [];
  List<Map<String, dynamic>> _topProducts = [];

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMonthly = false;
  bool _isLoadingProducts = false;

  // Error states
  String? _error;
  String? _monthlyError;
  String? _productsError;

  // Getters
  Map<String, dynamic> get analyticsData => _analyticsData;
  List<Map<String, dynamic>> get monthlyData => _monthlyData;
  List<Map<String, dynamic>> get topProducts => _topProducts;

  bool get isLoading => _isLoading;
  bool get isLoadingMonthly => _isLoadingMonthly;
  bool get isLoadingProducts => _isLoadingProducts;

  String? get error => _error;
  String? get monthlyError => _monthlyError;
  String? get productsError => _productsError;

  // Convenience getters for analytics data
  int get totalOrders => _analyticsData['totalOrders'] ?? 0;
  int get totalDelivered => _analyticsData['totalDelivered'] ?? 0;
  int get totalPaid => _analyticsData['totalPaid'] ?? 0;
  int get totalDelivering => _analyticsData['totalDelivering'] ?? 0;
  int get totalCanceled => _analyticsData['totalCanceled'] ?? 0;
  double get totalRevenue => _analyticsData['totalRevenue'] ?? 0.0;
  double get deliveredRevenue => _analyticsData['deliveredRevenue'] ?? 0.0;
  double get paidRevenue => _analyticsData['paidRevenue'] ?? 0.0;
  double get deliveringRevenue => _analyticsData['deliveringRevenue'] ?? 0.0;

  // Calculate success rate
  double get successRate {
    if (totalOrders == 0) return 0.0;
    return (totalDelivered / totalOrders) * 100;
  }

  // Calculate average order value
  double get averageOrderValue {
    if (totalOrders == 0) return 0.0;
    return totalRevenue / totalOrders;
  }

  // Load sales analytics
  Future<void> loadSalesAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analyticsData = await SalesAnalysisService.getSalesAnalytics();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading sales analytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load monthly sales data
  Future<void> loadMonthlySales() async {
    _isLoadingMonthly = true;
    _monthlyError = null;
    notifyListeners();

    try {
      _monthlyData = await SalesAnalysisService.getMonthlySales();
      _monthlyError = null;
    } catch (e) {
      _monthlyError = e.toString();
      print('Error loading monthly sales: $e');
    } finally {
      _isLoadingMonthly = false;
      notifyListeners();
    }
  }

  // Load top selling products
  Future<void> loadTopProducts() async {
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();

    try {
      _topProducts = await SalesAnalysisService.getTopSellingProducts();
      _productsError = null;
    } catch (e) {
      _productsError = e.toString();
      print('Error loading top products: $e');
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadSalesAnalytics(),
      loadMonthlySales(),
      loadTopProducts(),
    ]);
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadAllData();
  }

  // Get sales data by date range
  Future<Map<String, dynamic>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await SalesAnalysisService.getSalesByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('Failed to get sales by date range: $e');
    }
  }

  // Helper method to format currency
  String formatCurrency(double amount) {
    return 'RM${amount.toStringAsFixed(2)}';
  }

  // Helper method to get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'paid':
        return const Color(0xFF2196F3); // Blue
      case 'shipped':
      case 'delivering':
        return const Color(0xFFFF9800); // Orange
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  // Helper method to get month name
  String getMonthName(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;

    final month = int.tryParse(parts[1]) ?? 1;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}
