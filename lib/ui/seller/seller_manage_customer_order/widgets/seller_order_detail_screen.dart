// lib/ui/seller/seller_manage_customer_order/widgets/seller_order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    as firestore; // Use prefix for firestore
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/model/order.dart'; // Import Order model and OrderStatus enum

class SellerOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  Order? _order;
  Map<String, dynamic>? _customerInfo; // To store customer name and phone
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
        final orderData = Order.fromFirestore(docSnapshot);
        _order = orderData;

        // Fetch customer details using orderData.userId
        if (_order!.userId.isNotEmpty) {
          _customerInfo = await _fetchCustomerDetails(_order!.userId);
        }

        setState(() {
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

  // Method to fetch customer details from 'users' collection
  // 从 'users' 集合中获取客户详情的方法
  Future<Map<String, dynamic>?> _fetchCustomerDetails(String customerId) async {
    try {
      final docSnapshot =
          await _firestore
              .collection('users')
              .doc(customerId)
              .get(); // Assuming 'users' collection
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    } catch (e) {
      print('Error fetching customer details for $customerId: $e');
    }
    return null;
  }

  // Helper function to build an info row with horizontal layout
  // 辅助函数，用于显示单个信息行，采用并排（水平）排版
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
            _buildInfoRow(
              'Name',
              _customerInfo?['name'] ?? 'N/A',
            ), // Display fetched name from 'users' collection
            _buildInfoRow(
              'Email',
              _customerInfo?['email'] ?? 'N/A',
            ), // Display fetched email from 'users' collection
            _buildInfoRow(
              'Phone',
              _customerInfo?['phoneNumber'] ?? 'N/A',
            ), // Display fetched phone from 'users' collection
            const SizedBox(height: 16),

            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildInfoRow('Address 1', _order!.address['address1'] ?? 'N/A'),
            _buildInfoRow('Address 2', _order!.address['address2'] ?? 'N/A'),
            _buildInfoRow('City', _order!.address['city'] ?? 'N/A'),
            _buildInfoRow('Postcode', _order!.address['postcode'] ?? 'N/A'),
            _buildInfoRow('State', _order!.address['state'] ?? 'N/A'),
            const SizedBox(height: 16),

            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildInfoRow(
              'Total Amount',
              'RM ${_order!.amount.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Order Date',
              _order!.createdAt.toLocal().toString().split('.')[0],
            ),
            _buildInfoRow(
              'Status',
              _order!.status.name.toUpperCase(),
            ), // Changed to .name.toUpperCase()
            _buildInfoRow(
              'Payment Status',
              _order!.payment['status']?.toUpperCase() ?? 'N/A',
            ), // Payment status from 'payment' map
            _buildInfoRow(
              'Payment Type',
              _order!.payment['paymentType']?.toUpperCase() ?? 'N/A',
            ), // Payment type from 'payment' map
            const SizedBox(height: 16),

            const Text(
              'Products in Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Display list of products in the order
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order!.products.length,
              itemBuilder: (context, index) {
                final product = _order!.products[index];
                // Now, product name, price, quantity, color, size are directly in OrderProduct
                // Only imageUrl needs to be fetched from 'products' collection if not in OrderProduct
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
                        // Display product image (if available from OrderProduct, or fetch from product details)
                        // If product.imageUrl is directly available in OrderProduct model after parsing, use that.
                        // Otherwise, use FutureBuilder to fetch it from 'products' collection using product.itemId.
                        FutureBuilder<Map<String, dynamic>?>(
                          future: _fetchProductDetails(
                            product.itemId,
                          ), // Fetch full product details
                          builder: (context, snapshot) {
                            String displayImageUrl =
                                product.imageUrl ??
                                'https://placehold.co/60x60/cccccc/000000?text=No+Img';
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              if (snapshot.data!['images'] != null &&
                                  snapshot.data!['images'].isNotEmpty) {
                                displayImageUrl = snapshot.data!['images'][0];
                              }
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                displayImageUrl,
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
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product
                                    .name, // Use name directly from OrderProduct
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Color: ${product.color}',
                              ), // Use color directly
                              Text(
                                'Size: ${product.size ?? 'N/A'}',
                              ), // Use size directly
                              Text(
                                'Quantity: ${product.quantity}',
                              ), // Use quantity directly
                              Text(
                                'Price: RM ${product.price.toStringAsFixed(2)}',
                              ), // Use price directly
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
                      _order!.status == OrderStatus.pending
                          ? () {
                            // Compare with enum
                            _updateOrderStatus(
                              OrderStatus.shipped,
                            ); // Pass enum
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Mark as Shipped'),
                ),
                ElevatedButton(
                  onPressed:
                      _order!.status == OrderStatus.shipped
                          ? () {
                            // Compare with enum
                            _updateOrderStatus(
                              OrderStatus.delivered,
                            ); // Pass enum
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
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

  // Method to fetch full product details from 'products' collection (mainly for imageUrl now)
  // 用于从 'products' 集合中获取完整产品详情的方法（现在主要用于获取图片 URL）
  Future<Map<String, dynamic>?> _fetchProductDetails(String productId) async {
    try {
      final docSnapshot =
          await _firestore.collection('products').doc(productId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    } catch (e) {
      print('Error fetching product details for $productId: $e');
    }
    return null;
  }

  // Method to update order status in Firestore (now accepts OrderStatus enum)
  // 在 Firestore 中更新订单状态的方法（现在接受 OrderStatus 枚举）
  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    // Changed parameter type
    try {
      await _firestore.collection('orders').doc(widget.orderId).update({
        'status': newStatus.name, // Store enum name in Firestore
      });
      setState(() {
        _order?.status = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to ${newStatus.name}!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $e')),
      );
      print('❌ Failed to update order status: $e');
    }
  }
}
