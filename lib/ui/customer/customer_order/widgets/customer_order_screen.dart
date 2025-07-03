import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/customer_order_view_model.dart';
import 'package:mycrochetbag/domain/model/Order.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CustomerOrderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _viewModel = CustomerOrderViewModel();
    _viewModel.init();

    // Listen to tab changes to filter orders
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterOrdersByTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _filterOrdersByTab(int index) {
    switch (index) {
      case 0:
        _viewModel.filterOrders(null); // All orders
        break;
      case 1:
        _viewModel.filterOrders(OrderStatus.paid);
        break;
      case 2:
        _viewModel.filterOrders(OrderStatus.shipped);
        break;
      case 3:
        _viewModel.filterOrders(OrderStatus.delivered);
        break;
      case 4:
        _viewModel.filterOrders(OrderStatus.cancelled);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
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
        body: Consumer<CustomerOrderViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.error != null) {
              return _buildErrorWidget(viewModel);
            }

            return Column(
              children: [
                // Tab Bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
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
                    tabs: [
                      Tab(text: 'All (${viewModel.totalOrdersCount})'),
                      Tab(
                        text:
                            'Processing (${viewModel.getOrdersCountByStatus(OrderStatus.paid)})',
                      ),
                      Tab(
                        text:
                            'Shipped (${viewModel.getOrdersCountByStatus(OrderStatus.shipped)})',
                      ),
                      Tab(
                        text:
                            'Delivered (${viewModel.getOrdersCountByStatus(OrderStatus.delivered)})',
                      ),
                      Tab(
                        text:
                            'Cancelled (${viewModel.getOrdersCountByStatus(OrderStatus.cancelled)})',
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child:
                      viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                            onRefresh: viewModel.refreshOrders,
                            child: OrderListView(
                              orders: viewModel.filteredOrders,
                            ),
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(CustomerOrderViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error ?? 'Unknown error occurred',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              viewModel.clearError();
              viewModel.refreshOrders();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class OrderListView extends StatelessWidget {
  final List<OrderModel> orders;

  const OrderListView({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your orders will appear here',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
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
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  void _showOrderDetailPopup(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Order Detail",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Ordered Items",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                ...order.orders.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text("Size: ${item.size}"),
                        Text("Color: ${item.color}"),
                        Text("Quantity: ${item.quantity}"),
                        Text(
                          "Total: RM ${(item.price * item.quantity).toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 32),

                const Text(
                  "Payment Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text("Total Price: RM ${order.amount.toStringAsFixed(2)}"),
                Text("Payment Status: Paid"),
                Text("Payment Method: ${order.paymentType}"),

                const Divider(height: 32),

                const Text(
                  "Order Status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _getOrderStatusMessage(order.orderStatus),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (order.orderStatus == OrderStatus.shipped)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                      children: [
                        const TextSpan(text: 'Tracking ID: '),
                        TextSpan(
                          text: order.trackingId ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOrderDetailPopup(context, order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              order.orderStatus == OrderStatus.cancelled
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
                      _getStatusTitle(order.orderStatus),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.displayDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                if (order.orderStatus == OrderStatus.paid ||
                    order.orderStatus == OrderStatus.pending)
                  Consumer<CustomerOrderViewModel>(
                    builder:
                        (context, viewModel, _) => TextButton(
                          onPressed: () async {
                            await viewModel.cancelOrder(order.id, order.userId);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Order cancelled successfully.',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Cancel'),
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
                  child:
                      order.mainProductImageUrl.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              order.mainProductImageUrl,
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
                        'ORDER ID : ${order.merchantReference}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.mainProductName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RM ${order.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (order.orders.length > 1)
                        Text(
                          '+${order.orders.length - 1} more items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
            if (order.orderStatus == OrderStatus.cancelled) ...[
              const SizedBox(height: 12),
              Text(
                'Cancel Reason: ${order.cancelReason}',
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
      case OrderStatus.paid:
      case OrderStatus.pending:
        return 'Processing';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.shipped:
        return 'Shipped';
    }
  }

  String _getOrderStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
      case OrderStatus.pending:
        return "The seller will send your order";
      case OrderStatus.shipped:
        return "Your item is on delivery";
      case OrderStatus.delivered:
        return "The seller has sent your order";
      case OrderStatus.cancelled:
        return "Your order has been cancelled";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'shipped':
        return Colors.orange;
      case 'delivered':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
