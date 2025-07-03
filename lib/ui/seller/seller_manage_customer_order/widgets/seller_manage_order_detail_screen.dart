import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_customer_order/view_model/seller_manager_order_detail_view_model.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:mycrochetbag/domain/model/Address.dart';

class SellerManageOrderDetailScreen extends StatefulWidget {
  final String userId;
  final String orderId;

  const SellerManageOrderDetailScreen({
    required this.userId,
    required this.orderId,
    super.key,
  });

  @override
  _SellerManageOrderDetailScreenState createState() =>
      _SellerManageOrderDetailScreenState();
}

class _SellerManageOrderDetailScreenState
    extends State<SellerManageOrderDetailScreen> {
  SellerManageOrderDetailViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SellerManageOrderDetailViewModel();
    _viewModel!.loadOrders(widget.userId, widget.orderId);
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer<SellerManageOrderDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Scaffold(
              appBar: AppBar(title: Text('Order Details')),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null) {
            return Scaffold(
              appBar: AppBar(title: Text('Order Details')),
              body: Center(child: Text('Error: ${viewModel.error}')),
            );
          }

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Order Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: Column(
              children: [
                // Status Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _getStatusColor('${viewModel.order?.status}'),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon('${viewModel.order?.status}'),
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Order Status: ${viewModel.order?.status}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order ID Card
                        _buildInfoCard(
                          title: 'Order Information',
                          icon: Icons.receipt_long,
                          children: [
                            _buildOrderIdRow('${viewModel.order?.id}'),
                            SizedBox(height: 8),
                            _buildInfoRow(
                              'Order Date',
                              '${viewModel.order?.createdAt}',
                            ),
                            _buildInfoRow(
                              'Payment Method',
                              '${viewModel.order?.paymentType}',
                            ),
                            _buildInfoRow(
                              'Total Amount',
                              '${viewModel.order?.amount.toStringAsFixed(2)}',
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Customer Information Card
                        _buildInfoCard(
                          title: 'Customer Information',
                          icon: Icons.person,
                          children: [
                            _buildInfoRow(
                              'Full Name',
                              "${viewModel.user?.firstName} ${viewModel.user?.lastName}",
                            ),
                            _buildInfoRow('Email', '${viewModel.user?.email}'),
                            _buildInfoRow(
                              'Phone',
                              '${viewModel.user?.phoneNumber}',
                            ),
                            _buildInfoRow(
                              'Shipping Address',
                              '${viewModel.order?.address.fullAddress}',
                            ),
                          ],
                        ),

                        // Shipping Information Card
                        if (viewModel.shouldShowShippingInfo())
                          _buildInfoCard(
                            title: 'Shipping Information',
                            icon: Icons.local_shipping,
                            children: [
                              _buildAddressRow(viewModel.address!),
                              SizedBox(height: 8),
                              _buildInfoRow(
                                'Delivery Type',
                                'Standard Shipping',
                              ),
                              _buildInfoRow(
                                'Tracking ID',
                                '${viewModel.order?.trackingId}',
                              ),
                              _buildInfoRow('Estimated Delivery', '3-5 Days'),
                            ],
                          ),

                        if (viewModel.shouldShowCancelInfo())
                          _buildInfoCard(
                            title: 'Cancel Information',
                            icon: Icons.cancel_outlined,
                            children: [
                              _buildInfoRow(
                                'Canellation Reason',
                                '${viewModel.order?.cancelReason}',
                              ),
                            ],
                          ),

                        SizedBox(height: 16),

                        // Order Items Card
                        _buildInfoCard(
                          title: 'Order Items',
                          icon: Icons.shopping_bag,
                          children:
                              viewModel.order == null
                                  ? [Text('Loading order items...')]
                                  : [
                                    SizedBox(height: 10),
                                    ...viewModel.order!.orders.map(
                                      (item) => Column(
                                        children: [
                                          _buildOrderItem(
                                            item.name,
                                            item.quantity,
                                            item.price,
                                          ),
                                          Divider(
                                            height: 16,
                                            color: Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'RM ${viewModel.order!.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                        ),

                        SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar:
                viewModel.shouldShowUpdateButton()
                    ? Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _showUpdateStatusModal(viewModel);
                              },
                              child: Text(
                                'Update Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : null,
          );
        },
      ),
    );
  }

  // All your existing UI helper methods remain the same
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildOrderIdRow(String orderId) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                orderId,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: orderId));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order ID copied to clipboard')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(Address address) {
    return Row(
      children: [
        Expanded(
          child: Text(
            address.fullAddress,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(String name, int quantity, double price) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                'Qty: $quantity',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          'RM ${(price * quantity).toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'paid':
        return Colors.orange[600]!;
      case 'shipped':
        return Colors.blue[600]!;
      case 'delivered':
        return Colors.green[600]!;
      case 'cancelled':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'paid':
        return Icons.access_time;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _showUpdateStatusModal(SellerManageOrderDetailViewModel viewModel) {
    final _formKey = GlobalKey<FormState>();
    String? selectedStatus;
    String? trackingNumber;
    String? cancelReason;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final List<DropdownMenuItem<String>> statusOptions = [];
              final orderStatus =
                  viewModel.order?.status.toLowerCase() ?? 'pending';

              // Add dropdown options
              if (orderStatus == 'paid') {
                statusOptions.addAll([
                  DropdownMenuItem(
                    value: 'shipped',
                    child: Text('Shipped For Delivery'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ]);
              } else if (orderStatus == 'shipped') {
                statusOptions.add(
                  DropdownMenuItem(
                    value: 'delivered',
                    enabled: viewModel.isDeliveredEnabled(),
                    child: Text('Delivered'),
                  ),
                );
              }

              // Validate selectedStatus
              if (!statusOptions.any((item) => item.value == selectedStatus)) {
                selectedStatus = null;
              }

              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Order Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(labelText: 'Status'),
                        items: statusOptions,
                        onChanged: (val) {
                          if (val == null) return;
                          setModalState(() {
                            selectedStatus = val;

                            // Reset fields
                            if (selectedStatus != 'shipped')
                              trackingNumber = null;
                            if (selectedStatus != 'cancelled')
                              cancelReason = null;
                          });
                        },
                        validator:
                            (val) =>
                                val == null ? 'Please select a status' : null,
                      ),

                      SizedBox(height: 16),

                      if (selectedStatus == 'shipped')
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tracking Number',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => trackingNumber = val,
                          validator: (val) {
                            if (selectedStatus == 'shipped' &&
                                (val == null || val.trim().isEmpty)) {
                              return 'Tracking number is required';
                            }
                            return null;
                          },
                        ),

                      if (selectedStatus == 'cancelled')
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Cancellation Reason',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => cancelReason = val,
                            validator: (val) {
                              if (selectedStatus == 'cancelled' &&
                                  (val == null || val.trim().isEmpty)) {
                                return 'Cancellation reason is required';
                              }
                              return null;
                            },
                          ),
                        ),

                      SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);

                            await viewModel.updateOrderStatus(
                              status: selectedStatus!,
                              trackingNumber: trackingNumber,
                              cancelReason: cancelReason,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Order status updated')),
                            );
                          }
                        },
                        child: Text('Update'),
                      ),

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
