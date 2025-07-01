// lib/ui/seller/seller_manage_customer_order/widgets/seller_order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/view_model/seller_order_list_view_model.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/widgets/seller_order_detail_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/model/order.dart'; // Import Order and OrderStatus enum

class SellerOrderListScreen extends StatefulWidget {
  const SellerOrderListScreen({super.key});

  @override
  State<SellerOrderListScreen> createState() => _SellerOrderListScreenState();
}

class _SellerOrderListScreenState extends State<SellerOrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Total 7 tabs: All, Pending, Paid, Processing, Shipped, Delivered, Cancelled
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabSelection); // Listen to tab changes
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging ||
        !_tabController.indexIsChanging &&
            _tabController.index == _tabController.previousIndex) {
      // Only update filter if tab is actually changing
      final viewModel = context.read<SellerOrderListViewModel>();
      switch (_tabController.index) {
        case 0: // All
          viewModel.setSelectedStatusFilter(null);
          break;
        case 1: // Pending
          viewModel.setSelectedStatusFilter(OrderStatus.pending);
          break;
        case 2: // Paid
          viewModel.setSelectedStatusFilter(OrderStatus.paid);
          break;
        case 3: // Processing
          viewModel.setSelectedStatusFilter(OrderStatus.processing);
          break;
        case 4: // Shipped
          viewModel.setSelectedStatusFilter(OrderStatus.shipped);
          break;
        case 5: // Delivered
          viewModel.setSelectedStatusFilter(OrderStatus.delivered);
          break;
        case 6: // Cancelled
          viewModel.setSelectedStatusFilter(OrderStatus.cancelled);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerOrderListViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Customer Orders', // Seller's view of Customer Orders
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
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true, // Make tabs scrollable if many
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
              Tab(text: 'Pending'),
              Tab(text: 'Paid'),
              Tab(text: 'Processing'),
              Tab(text: 'Shipped'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: Consumer<SellerOrderListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // All Orders
                _OrderListContent(
                  orders: viewModel.allOrders,
                  viewModel: viewModel,
                ), // Pass allOrders for 'All' tab
                // Filtered by status for other tabs
                _OrderListContent(
                  orders:
                      viewModel.allOrders
                          .where((o) => o.status == OrderStatus.pending)
                          .toList(),
                  viewModel: viewModel,
                ),
                _OrderListContent(
                  orders:
                      viewModel.allOrders
                          .where((o) => o.status == OrderStatus.paid)
                          .toList(),
                  viewModel: viewModel,
                ),
                _OrderListContent(
                  orders:
                      viewModel.allOrders
                          .where((o) => o.status == OrderStatus.processing)
                          .toList(),
                  viewModel: viewModel,
                ),
                _OrderListContent(
                  orders:
                      viewModel.allOrders
                          .where((o) => o.status == OrderStatus.shipped)
                          .toList(),
                  viewModel: viewModel,
                ),
                _OrderListContent(
                  orders:
                      viewModel.allOrders
                          .where((o) => o.status == OrderStatus.delivered)
                          .toList(),
                  viewModel: viewModel,
                ),
                _OrderListContent(
                  orders:
                      viewModel.allOrders
                          .where((o) => o.status == OrderStatus.cancelled)
                          .toList(),
                  viewModel: viewModel,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Reusable widget to display a list of orders (similar to OrderListView from customer)
class _OrderListContent extends StatelessWidget {
  final List<Order> orders;
  final SellerOrderListViewModel viewModel;

  const _OrderListContent({required this.orders, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders found for this status.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(
            order: order,
            viewModel: viewModel,
          ); // Pass viewmodel to refresh
        },
      ),
    );
  }
}

// Order Card widget (similar to OrderCard from customer, but adapted for seller's Order model)
class _OrderCard extends StatelessWidget {
  final Order order;
  final SellerOrderListViewModel
  viewModel; // To trigger refresh on detail screen return

  const _OrderCard({required this.order, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Determine the image for the order card (e.g., first product image)
    final String firstProductImageUrl =
        order.products.isNotEmpty &&
                order.products.first.imageUrl != null &&
                order.products.first.imageUrl!.isNotEmpty
            ? order.products.first.imageUrl!
            : 'https://placehold.co/60x60/cccccc/000000?text=No+Img'; // Placeholder

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerOrderDetailScreen(orderId: order.id),
          ),
        );
        viewModel.refreshOrders(); // Refresh list after returning from detail
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              order.status == OrderStatus.cancelled
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
                      'Order Date: ${order.createdAt.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    // Make onPressed async to await Navigator.push
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                SellerOrderDetailScreen(orderId: order.id),
                      ),
                    );
                    viewModel.refreshOrders(); // Refresh after returning
                  },
                  child: const Text(
                    'View Details', // Changed to 'View Details' for clarity
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
            // Order details row (first product, if any)
            if (order.products.isNotEmpty)
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        firstProductImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Order info (Product Name and Total)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order
                              .products
                              .first
                              .name, // Display first product name
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RM ${order.amount.toStringAsFixed(2)}', // Display total order amount
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
            // "No products in this order" message if products list is empty
            if (order.products.isEmpty)
              const Text(
                'No products in this order.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            // Cancelled order note
            if (order.status == OrderStatus.cancelled) ...[
              const SizedBox(height: 12),
              Text(
                // Display who cancelled (customer ID) - This needs order.userId to be the customer ID
                // or if you have a field for 'cancelledBy'
                'Order cancelled by customer (ID: ${order.userId.substring(0, 8)}...)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  // Helper to get status title string
  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.pending:
        return 'Pending';
    }
  }

  // Helper to get status color
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green[700]!;
      case OrderStatus.processing:
        return Colors.orange[700]!;
      case OrderStatus.cancelled:
        return Colors.red[700]!;
      case OrderStatus.paid:
        return Colors.purple[700]!;
      case OrderStatus.shipped:
        return Colors.blue[700]!;
      case OrderStatus.pending:
        return Colors.orange[400]!; // Lighter orange for pending
    }
  }
}
