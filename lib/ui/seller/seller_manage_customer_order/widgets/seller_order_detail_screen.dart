// lib/ui/seller/seller_manage_customer_order/widgets/seller_order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    as firestore; // Use prefix for firestore to avoid naming conflicts
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/model/order.dart'; // Import Order model

class SellerOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance; // Use prefixed Firestore
  Order? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final docSnapshot =
          await _firestore.collection('orders').doc(widget.orderId).get();
      if (docSnapshot.exists) {
        setState(() {
          _order = Order.fromFirestore(docSnapshot);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Order not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching order details: $e';
        _isLoading = false;
      });
      print('❌ Error fetching order details: $e');
    }
  }

  // Helper function to build an info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width to align labels
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order data not available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${_order!.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),

            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildInfoRow('Name', _order!.customerName),
            _buildInfoRow('Email', _order!.customerEmail),
            const SizedBox(height: 16),

            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildInfoRow('Street', _order!.shippingAddress['street'] ?? 'N/A'),
            _buildInfoRow('City', _order!.shippingAddress['city'] ?? 'N/A'),
            _buildInfoRow('Zip Code', _order!.shippingAddress['zip'] ?? 'N/A'),
            _buildInfoRow(
              'State',
              _order!.shippingAddress['state'] ?? 'N/A',
            ), // Assuming state might be included
            _buildInfoRow(
              'Country',
              _order!.shippingAddress['country'] ?? 'N/A',
            ), // Assuming country might be included
            const SizedBox(height: 16),

            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildInfoRow(
              'Total Amount',
              'RM ${_order!.totalAmount.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Order Date',
              _order!.orderDate.toLocal().toString().split('.')[0],
            ), // Display up to seconds
            _buildInfoRow(
              'Status',
              _order!.status.toUpperCase(),
            ), // Display status in uppercase
            const SizedBox(height: 16),

            const Text(
              'Products in Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Display list of products in the order
            ListView.builder(
              shrinkWrap:
                  true, // Ensure ListView works correctly inside a Column
              physics:
                  const NeverScrollableScrollPhysics(), // Disable internal scrolling
              itemCount: _order!.products.length,
              itemBuilder: (context, index) {
                final product = _order!.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        if (product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Quantity: ${product.quantity}'),
                              Text(
                                'Price: RM ${product.price.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Optional: Add buttons for updating order status if needed
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      _order!.status == 'pending'
                          ? () {
                            // Example: update status to 'shipped'
                            _updateOrderStatus('shipped');
                          }
                          : null, // Disable button if not pending
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Mark as Shipped'),
                ),
                ElevatedButton(
                  onPressed:
                      _order!.status == 'shipped'
                          ? () {
                            // Example: update status to 'delivered'
                            _updateOrderStatus('delivered');
                          }
                          : null, // Disable button if not shipped
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(
                          context,
                        ).secondaryHeaderColor, // A different color for delivery
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  child: const Text('Mark as Delivered'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to update order status in Firestore
  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      await _firestore.collection('orders').doc(widget.orderId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus!')),
      );
      // Refresh the screen after update
      _fetchOrderDetail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $e')),
      );
      print('❌ Failed to update order status: $e');
    }
  }
}
