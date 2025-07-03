import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/domain/model/CustomerOrder.dart';

class SalesAnalysisService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';

  // Get sales analytics data
  static Future<Map<String, dynamic>> getSalesAnalytics() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collectionGroup(_ordersCollection)
              .where('status', isNotEqualTo: "pending")
              .get();

      final orders =
          querySnapshot.docs
              .map((doc) => CustomerOrder.fromFirestore(doc))
              .toList();

      // Calculate totals
      int totalDelivered = 0;
      int totalPaid = 0;
      int totalDelivering = 0;
      int totalCanceled = 0;
      double totalRevenue = 0.0;
      double deliveredRevenue = 0.0;
      double paidRevenue = 0.0;
      double deliveringRevenue = 0.0;

      for (var order in orders) {
        switch (order.status.toLowerCase()) {
          case 'completed':
          case 'delivered':
            totalDelivered++;
            deliveredRevenue += order.amount;
            break;
          case 'paid':
            totalPaid++;
            paidRevenue += order.amount;
            break;
          case 'shipped':
          case 'delivering':
            totalDelivering++;
            deliveringRevenue += order.amount;
            break;
          case 'cancelled':
            totalCanceled++;
            break;
        }

        // Add to total revenue only if not cancelled
        if (order.status.toLowerCase() != 'cancelled') {
          totalRevenue += order.amount;
        }
      }

      return {
        'totalOrders': orders.length,
        'totalDelivered': totalDelivered,
        'totalPaid': totalPaid,
        'totalDelivering': totalDelivering,
        'totalCanceled': totalCanceled,
        'totalRevenue': totalRevenue,
        'deliveredRevenue': deliveredRevenue,
        'paidRevenue': paidRevenue,
        'deliveringRevenue': deliveringRevenue,
        'orders': orders,
      };
    } catch (e) {
      throw Exception('Failed to fetch sales analytics: $e');
    }
  }

  // Get monthly sales data for charts
  static Future<List<Map<String, dynamic>>> getMonthlySales() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collectionGroup(_ordersCollection)
              .where('status', isNotEqualTo: "pending")
              .where('status', isNotEqualTo: "cancelled")
              .orderBy('createdAt', descending: false)
              .get();

      final orders =
          querySnapshot.docs
              .map((doc) => CustomerOrder.fromFirestore(doc))
              .toList();

      // Group orders by month
      Map<String, double> monthlyRevenue = {};
      Map<String, int> monthlyCount = {};

      for (var order in orders) {
        final month =
            '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}';

        monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + order.amount;
        monthlyCount[month] = (monthlyCount[month] ?? 0) + 1;
      }

      // Convert to list for charts
      List<Map<String, dynamic>> monthlyData = [];
      monthlyRevenue.forEach((month, revenue) {
        monthlyData.add({
          'month': month,
          'revenue': revenue,
          'count': monthlyCount[month] ?? 0,
        });
      });

      return monthlyData;
    } catch (e) {
      throw Exception('Failed to fetch monthly sales: $e');
    }
  }

  // Get top selling products
  static Future<List<Map<String, dynamic>>> getTopSellingProducts() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collectionGroup(_ordersCollection)
              .where('status', isNotEqualTo: "pending")
              .where('status', isNotEqualTo: "cancelled")
              .get();

      final orders =
          querySnapshot.docs
              .map((doc) => CustomerOrder.fromFirestore(doc))
              .toList();

      // Group products by name and calculate totals
      Map<String, Map<String, dynamic>> productStats = {};

      for (var order in orders) {
        for (var item in order.orders) {
          if (productStats.containsKey(item.name)) {
            productStats[item.name]!['quantity'] += item.quantity;
            productStats[item.name]!['revenue'] += item.price * item.quantity;
          } else {
            productStats[item.name] = {
              'name': item.name,
              'quantity': item.quantity,
              'revenue': item.price * item.quantity,
            };
          }
        }
      }

      // Convert to list and sort by quantity
      List<Map<String, dynamic>> topProducts = productStats.values.toList();
      topProducts.sort((a, b) => b['quantity'].compareTo(a['quantity']));

      return topProducts.take(10).toList(); // Return top 10 products
    } catch (e) {
      throw Exception('Failed to fetch top selling products: $e');
    }
  }

  // Get sales data by date range
  static Future<Map<String, dynamic>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collectionGroup(_ordersCollection)
              .where('createdAt', isGreaterThanOrEqualTo: startDate)
              .where('createdAt', isLessThanOrEqualTo: endDate)
              .where('status', isNotEqualTo: "pending")
              .get();

      final orders =
          querySnapshot.docs
              .map((doc) => CustomerOrder.fromFirestore(doc))
              .toList();

      double totalRevenue = 0.0;
      int totalOrders = 0;

      for (var order in orders) {
        if (order.status.toLowerCase() != 'cancelled') {
          totalRevenue += order.amount;
          totalOrders++;
        }
      }

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
        'orders': orders,
      };
    } catch (e) {
      throw Exception('Failed to fetch sales by date range: $e');
    }
  }
}
