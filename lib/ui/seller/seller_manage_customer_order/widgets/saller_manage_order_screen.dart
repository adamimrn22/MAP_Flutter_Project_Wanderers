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
  final TextEditingController _searchController = TextEditingController();

  // Data lists
  List<CustomerOrder> _allOrders = [];
  List<CustomerOrder> _filteredOrders = [];
  List<CustomerOrder> _displayedOrders = [];

  // State variables
  bool _isLoading = false;
  String? _error;
  bool _isSearching = false;

  // Filter options
  String _sortBy = 'date'; // date, amount, status
  bool _sortAscending = false;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _filterOrders(_tabController.index);
    }
  }

  void _onSearchChanged() {
    _applySearchAndFilters();
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
        _allOrders = orders;
        _filteredOrders = orders;
        _displayedOrders = orders;
        _isLoading = false;
      });
      _applySearchAndFilters();
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
          filtered = _allOrders;
          break;
        case 1: // Paid
          filtered =
              _allOrders
                  .where((order) => order.status.toLowerCase() == "paid")
                  .toList();
          break;
        case 2: // Shipped
          filtered =
              _allOrders
                  .where((order) => order.status.toLowerCase() == "shipped")
                  .toList();
          break;
        case 3: // Completed
          filtered =
              _allOrders
                  .where((order) => order.status.toLowerCase() == "delivered")
                  .toList();
          break;
        case 4: // Cancelled
          filtered =
              _allOrders
                  .where((order) => order.status.toLowerCase() == "cancelled")
                  .toList();
          break;
        default:
          filtered = _allOrders;
      }

      setState(() {
        _filteredOrders = filtered;
        _isLoading = false;
      });
      _applySearchAndFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applySearchAndFilters() {
    List<CustomerOrder> result = List.from(_filteredOrders);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      result =
          result.where((order) {
            // Search by order ID
            if (order.id.toLowerCase().contains(searchTerm)) return true;

            // Search by product names
            for (var item in order.orders) {
              if (item.name.toLowerCase().contains(searchTerm)) return true;
            }

            // Search by amount
            if (order.amount.toString().contains(searchTerm)) return true;

            // Search by status
            if (order.status.toLowerCase().contains(searchTerm)) return true;

            return false;
          }).toList();
    }

    // Apply date range filter
    if (_dateRange != null) {
      result =
          result.where((order) {
            return order.createdAt.isAfter(
                  _dateRange!.start.subtract(Duration(days: 1)),
                ) &&
                order.createdAt.isBefore(
                  _dateRange!.end.add(Duration(days: 1)),
                );
          }).toList();
    }

    // Apply sorting
    result.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _displayedOrders = result;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Filter & Sort'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sort by section
                      Text(
                        'Sort by:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(value: 'date', child: Text('Date')),
                          DropdownMenuItem(
                            value: 'amount',
                            child: Text('Amount'),
                          ),
                          DropdownMenuItem(
                            value: 'status',
                            child: Text('Status'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _sortAscending,
                            onChanged: (value) {
                              setDialogState(() {
                                _sortAscending = value!;
                              });
                            },
                          ),
                          Text('Ascending'),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Date range section
                      Text(
                        'Date Range:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final range = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  initialDateRange: _dateRange,
                                );
                                if (range != null) {
                                  setDialogState(() {
                                    _dateRange = range;
                                  });
                                }
                              },
                              child: Text(
                                _dateRange == null
                                    ? 'Select Date Range'
                                    : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                              ),
                            ),
                          ),
                          if (_dateRange != null)
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setDialogState(() {
                                  _dateRange = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          // Apply filters
                        });
                        _applySearchAndFilters();
                        Navigator.pop(context);
                      },
                      child: Text('Apply'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Order Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadOrders,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSearching ? 108 : 48),
          child: Column(
            children: [
              if (_isSearching)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by order ID, product name, amount...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              TabBar(
                isScrollable: true,
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[200],
                indicatorColor: Colors.white,
                indicatorWeight: 2,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
            ],
          ),
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

    return Column(
      children: [
        // Results summary
        if (_searchController.text.isNotEmpty || _dateRange != null)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Found ${_displayedOrders.length} orders',
                    style: TextStyle(color: Colors.blue[700], fontSize: 14),
                  ),
                ),
                if (_searchController.text.isNotEmpty || _dateRange != null)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _dateRange = null;
                      });
                      _applySearchAndFilters();
                    },
                    child: Text('Clear'),
                  ),
              ],
            ),
          ),

        // Orders list
        Expanded(
          child:
              _displayedOrders.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No orders found'),
                      ],
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _displayedOrders.length,
                      itemBuilder: (context, index) {
                        final order = _displayedOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
                  ),
        ),
      ],
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
