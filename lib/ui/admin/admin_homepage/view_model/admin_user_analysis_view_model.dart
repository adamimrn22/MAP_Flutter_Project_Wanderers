import 'package:flutter/material.dart';
import 'package:mycrochetbag/domain/model/User.dart';
import 'package:mycrochetbag/data/services/user_analysis_service.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodel.dart';
import 'package:mycrochetbag/utils/result.dart';

class AdminHomepageViewModel extends ChangeNotifier {
  final UserAnalysisService _userAnalysisService = UserAnalysisService();
  final SignoutViewmodel _signoutViewmodel = SignoutViewmodel();

  // Loading states
  bool _isLoading = false;
  bool _isInitialized = false;

  // Error handling
  String? _error;

  // User analytics data
  int _totalUsers = 0;
  Map<String, int> _roleDistribution = {};
  List<User> _recentUsers = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  int get totalUsers => _totalUsers;
  Map<String, int> get roleDistribution => _roleDistribution;
  List<User> get recentUsers => _recentUsers;

  // Computed properties
  int get totalAdmins => _roleDistribution['admin'] ?? 0;
  int get totalSellers => _roleDistribution['seller'] ?? 0;
  int get totalBuyers => _roleDistribution['buyer'] ?? 0;
  int get totalRegularUsers => _roleDistribution['user'] ?? 0;

  double get adminPercentage =>
      _totalUsers > 0 ? (totalAdmins / _totalUsers) * 100 : 0;
  double get sellerPercentage =>
      _totalUsers > 0 ? (totalSellers / _totalUsers) * 100 : 0;
  double get buyerPercentage =>
      _totalUsers > 0 ? (totalBuyers / _totalUsers) * 100 : 0;
  double get userPercentage =>
      _totalUsers > 0 ? (totalRegularUsers / _totalUsers) * 100 : 0;

  Future<void> loadUserAnalytics() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _userAnalysisService.getUserAnalytics();

      switch (result) {
        case Ok():
          final data = result.value;
          _totalUsers = data['totalUsers'] ?? 0;
          _roleDistribution = Map<String, int>.from(
            data['roleDistribution'] ?? {},
          );
          _recentUsers = List<User>.from(data['recentUsers'] ?? []);
          _isInitialized = true;
          break;
        case Error():
          _setError(result.error.toString());
          break;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData() async {
    await loadUserAnalytics();
  }

  void signout() {
    _signoutViewmodel.signout();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get role color for UI
  Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.blue;
      case 'buyer':
        return Colors.green;
      case 'user':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Get role icon
  IconData getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'seller':
        return Icons.store;
      case 'buyer':
        return Icons.shopping_cart;
      case 'user':
        return Icons.person;
      default:
        return Icons.group;
    }
  }

  // Format role name for display
  String formatRoleName(String role) {
    return role.substring(0, 1).toUpperCase() + role.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
