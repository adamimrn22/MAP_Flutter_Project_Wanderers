// lib/ui/seller/seller_manage_customer_order/widgets/seller_order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/view_model/seller_order_list_view_model.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/widgets/seller_order_detail_screen.dart'; // Import order detail page

class SellerOrderListScreen extends StatelessWidget {
  const SellerOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerOrderListViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Orders'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

            if (viewModel.filteredOrders.isEmpty) {
              return const Center(
                child: Text(
                  "No orders found.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return Column(
              children: [
                // Order status filter dropdown
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                    ),
                    value: viewModel.selectedStatusFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Orders')),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ), // Match Firestore status
                      DropdownMenuItem(
                        value: 'shipped',
                        child: Text('Shipped'),
                      ),
                      DropdownMenuItem(
                        value: 'delivered',
                        child: Text('Delivered'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.setSelectedStatusFilter(value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: viewModel.filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = viewModel.filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            'Order ID: ${order.id.substring(0, 8)}...',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer: ${order.customerName}'),
                              Text(
                                'Total: RM ${order.totalAmount.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Status: ${order.status.toUpperCase()}',
                              ), // Display status in uppercase
                              Text(
                                'Date: ${order.orderDate.toLocal().toString().split(' ')[0]}',
                              ), // Display only date
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            // Navigate to order detail page
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SellerOrderDetailScreen(
                                      orderId: order.id,
                                    ),
                              ),
                            );
                            // Refresh order list after returning from detail page (in case status was updated)
                            viewModel.refreshOrders();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
