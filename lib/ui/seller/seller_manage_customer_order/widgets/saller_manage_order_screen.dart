import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/data/services/manage_order_service.dart';
import 'package:mycrochetbag/domain/model/CustomerOrder.dart';
import 'package:mycrochetbag/domain/model/OrderItem.dart';
import 'package:mycrochetbag/routing/routes.dart';

class SallerManageOrderScreen extends StatefulWidget {
  const SallerManageOrderScreen({super.key});

  @override
  _SallerManageOrderScreenState createState() =>
      _SallerManageOrderScreenState();
}

class _SallerManageOrderScreenState extends State<SallerManageOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CustomerOrder> _orders = [];
  List<CustomerOrder> _filteredOrders = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _filterOrders(_tabController.index);
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await ManageOrderService.getAllOrders();
      print("all order $orders");
      setState(() {
        // _orders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _filterOrders(int tabIndex) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<CustomerOrder> filtered;
      switch (tabIndex) {
        case 0: // All
          filtered = await ManageOrderService.getAllOrders();
          break;
        case 1: // Paid because we dont want pending because pending is still not confirmed
          filtered = await ManageOrderService.getOrdersByStatus("paid");
          break;
        case 2: // Shipped (Shipped orders)
          filtered = await ManageOrderService.getOrdersByStatus("shipped");
          break;
        case 3: // Cancelled
          filtered = await ManageOrderService.getOrdersByStatus("completed");
          break;
        case 4: // Cancelled
          filtered = await ManageOrderService.getOrdersByStatus("cancelled");
          break;
        default:
          filtered = _orders;
      }

      setState(() {
        _filteredOrders = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Order Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          labelColor: Colors.white, // ✅ Active tab text color
          unselectedLabelColor: Colors.grey[200], // Inactive tab text color
          indicatorColor: Colors.white, // ✅ Bottom line indicator color
          indicatorWeight: 2,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          padding: EdgeInsets.zero,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Shipped'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading orders...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadOrders, child: Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No orders found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(CustomerOrder order) {
    final firstItem = order.orders.isNotEmpty ? order.orders.first : null;
    final totalQuantity = order.orders.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return GestureDetector(
      onTap: () => context.push('/seller/order/${order.userId}/${order.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Track',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              _formatDate(order.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem?.name ?? 'Order Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'ORDER ID : ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              order.id,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'x$totalQuantity',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.brown[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.brown[600],
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: RM${order.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Pending';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'delivered':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
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
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return 'on ${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}
