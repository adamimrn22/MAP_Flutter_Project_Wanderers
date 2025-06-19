import 'package:flutter/material.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample order data
  final List<OrderItem> orders = [
    OrderItem(
      id: "P09727004656",
      price: 22.90,
      status: OrderStatus.delivered,
      date: "03 Mar, 3 Sept",
      imageUrl: "assets/bag.png", // You'll need to add this asset
    ),
    OrderItem(
      id: "P09727004656",
      price: 22.90,
      status: OrderStatus.processing,
      date: "03 Mar, 3 Sept",
      imageUrl: "assets/bag.png",
    ),
    OrderItem(
      id: "P09727004656",
      price: 22.90,
      status: OrderStatus.cancelled,
      date: "Order cancelled by the user",
      imageUrl: "assets/bag.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderItem> getFilteredOrders(OrderStatus? status) {
    if (status == null) return orders;
    return orders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.black,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Processing'),
                Tab(text: 'Delivered'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Orders
                OrderListView(orders: getFilteredOrders(null)),
                // Processing Orders
                OrderListView(orders: getFilteredOrders(OrderStatus.processing)),
                // Delivered Orders
                OrderListView(orders: getFilteredOrders(OrderStatus.delivered)),
                // Cancelled Orders
                OrderListView(orders: getFilteredOrders(OrderStatus.cancelled)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderListView extends StatelessWidget {
  final List<OrderItem> orders;

  const OrderListView({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders found',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order);
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderItem order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: order.status == OrderStatus.cancelled 
            ? Colors.grey[100] 
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusTitle(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.date,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Handle track order
                },
                child: const Text(
                  'Track',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Order details row
          Row(
            children: [
              // Product image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: order.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          order.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 16),
              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER ID : ${order.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'RM ${order.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
          // Cancelled order note
          if (order.status == OrderStatus.cancelled) ...[
            const SizedBox(height: 12),
            Text(
              'The order was cancelled by the user',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFD4A574), // Beige color similar to the bag
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green[700]!;
      case OrderStatus.processing:
        return Colors.orange[700]!;
      case OrderStatus.cancelled:
        return Colors.red[700]!;
    }
  }
}

// Data models
enum OrderStatus {
  delivered,
  processing,
  cancelled,
}

class OrderItem {
  final String id;
  final double price;
  final OrderStatus status;
  final String date;
  final String imageUrl;

  OrderItem({
    required this.id,
    required this.price,
    required this.status,
    required this.date,
    required this.imageUrl,
  });
}