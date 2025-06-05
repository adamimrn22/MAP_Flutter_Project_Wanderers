import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:mycrochetbag/ui/customer/customer_view_bag/view_model/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/domain/model/CartItem.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartViewModel = context.read<CartViewModel?>();
      cartViewModel?.loadCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Consumer<CartViewModel>(
            builder: (context, cartViewModel, child) {
              if (cartViewModel.isEmpty) return const SizedBox.shrink();

              return TextButton(
                onPressed: () => _showClearCartDialog(context),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          // Show loading indicator
          if (cartViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message
          if (cartViewModel.errorMessage != null) {
            return _buildErrorState(cartViewModel);
          }

          // Show empty cart
          if (cartViewModel.isEmpty) {
            return _buildEmptyState();
          }

          // Show cart content
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cartViewModel.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartViewModel.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartViewModel.cartItems[index];
                      return _buildCartItemCard(
                        context,
                        cartItem,
                        cartViewModel,
                      );
                    },
                  ),
                ),
              ),
              _buildCartSummary(cartViewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartItem cartItem,
    CartViewModel cartViewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child:
                  cartItem.imageUrl != null && cartItem.imageUrl!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          cartItem.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      )
                      : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Text(
                        'Size: ${cartItem.size}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (cartItem.color != null &&
                          cartItem.color!.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Text(
                          'Color: ${cartItem.color}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        'RM ${cartItem.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        'RM ${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildQuantityControls(cartItem, cartViewModel),
                      const Spacer(),
                      IconButton(
                        onPressed:
                            cartViewModel.isUpdating
                                ? null
                                : () => _showRemoveItemDialog(
                                  context,
                                  cartItem,
                                  cartViewModel,
                                ),
                        icon: const Icon(
                          TablerIcons.trash_filled,
                          color: Colors.red,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
    CartItem cartItem,
    CartViewModel cartViewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap:
                cartViewModel.isUpdating
                    ? null
                    : () => cartViewModel.decreaseQuantity(cartItem.id),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Icon(Icons.remove, size: 16, color: Colors.black),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              '${cartItem.quantity}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          InkWell(
            onTap:
                cartViewModel.isUpdating
                    ? null
                    : () => cartViewModel.increaseQuantity(cartItem.id),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Icon(Icons.add, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartViewModel cartViewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            _buildSummaryRow(
              'Subtotal',
              'RM ${cartViewModel.totalPrice.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),

            _buildSummaryRow('Delivery Fee', 'RM 10.00', isGrey: true),
            const SizedBox(height: 8),

            _buildSummaryRow('Processing Fee', 'RM 5.00', isGrey: true),
            const SizedBox(height: 16),

            const Divider(),
            const SizedBox(height: 8),

            _buildSummaryRow(
              'Total',
              'RM ${(cartViewModel.totalPrice + 15.00).toStringAsFixed(2)}',
              isBold: true,
              fontSize: 18,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    cartViewModel.isUpdating
                        ? null
                        : () => _proceedToCheckout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    cartViewModel.isUpdating
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isGrey = false,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isGrey ? Colors.grey[600] : Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        size: 32,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(TablerIcons.shopping_bag, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some items to get started',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(CartViewModel cartViewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cartViewModel.errorMessage ?? 'Unknown error occurred',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                cartViewModel.clearError();
                cartViewModel.refresh();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveItemDialog(
    BuildContext context,
    CartItem cartItem,
    CartViewModel cartViewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: Text(
            'Are you sure you want to remove "${cartItem.name}" from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cartViewModel.removeItem(cartItem.id);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CartViewModel>().clearCart();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Proceeding to checkout...')));
  }
}
