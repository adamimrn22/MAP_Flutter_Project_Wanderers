import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/data/services/bag_service.dart';
import 'package:mycrochetbag/data/services/cart_service.dart';
import 'package:mycrochetbag/ui/customer/customer_view_bag/view_model/customer_view_bag_viewmodel.dart';
import 'package:provider/provider.dart';

class BagDetailScreen extends StatefulWidget {
  final String productId;

  const BagDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<BagDetailScreen> createState() => _BagDetailScreenState();
}

class _BagDetailScreenState extends State<BagDetailScreen> {
  late BagDetailViewModel _viewModel;
  final AuthServices _authService = AuthServices();
  User? user;

  @override
  void initState() {
    super.initState();
    user = _authService.currentUser;

    final userId = user?.uid;
    _viewModel = BagDetailViewModel(
      FirestoreBagServices(),
      FirestoreCartService(),
      userId!,
    );
    // Load product details
    _viewModel.loadProductDetails(widget.productId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Consumer<BagDetailViewModel>(
            builder: (context, viewModel, child) {
              return Text(
                viewModel.productName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          centerTitle: true,
        ),
        body: Consumer<BagDetailViewModel>(
          builder: (context, viewModel, child) {
            // Show error state
            if (viewModel.errorMessage != null) {
              return _buildErrorState(viewModel);
            }

            // Show loading state
            if (viewModel.isScreenLoading) {
              return _buildLoadingState();
            }

            // Show main content
            return _buildMainContent(viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BagDetailViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? 'Something went wrong',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              viewModel.clearError();
              viewModel.loadProductDetails(widget.productId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          SizedBox(height: 16),
          Text(
            'Loading product details...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BagDetailViewModel viewModel) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Images
                _buildImageCarousel(viewModel),

                // Image indicators
                if (viewModel.images.length > 1)
                  _buildImageIndicators(viewModel),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name and Price
                      _buildProductHeader(viewModel),

                      const SizedBox(height: 16),

                      // Description
                      _buildDescription(viewModel),

                      const SizedBox(height: 24),

                      // Size Selection
                      _buildSizeSelection(viewModel),

                      const SizedBox(height: 24),

                      // Color Selection
                      _buildColorSelection(viewModel),

                      const SizedBox(height: 24),

                      // Category and Material
                      _buildProductInfo(viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add to Cart Button
        _buildAddToCartButton(viewModel),
      ],
    );
  }

  Widget _buildImageCarousel(BagDetailViewModel viewModel) {
    return Container(
      height: 300,
      child: PageView.builder(
        itemCount: viewModel.images.length,
        onPageChanged: viewModel.updateImageIndex,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: Image.network(
              viewModel.images[index],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageIndicators(BagDetailViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          viewModel.images.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  viewModel.currentImageIndex == index
                      ? Colors.black
                      : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader(BagDetailViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            viewModel.productName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Text(
          'RM ${viewModel.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BagDetailViewModel viewModel) {
    return Text(
      viewModel.description,
      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
    );
  }

  Widget _buildSizeSelection(BagDetailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children:
              viewModel.sizes.map((size) {
                final isSelected = viewModel.selectedSize == size;
                return GestureDetector(
                  onTap: () => viewModel.selectSize(size),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelection(BagDetailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children:
              viewModel.colors.map((color) {
                final isSelected = viewModel.selectedColor == color;
                return GestureDetector(
                  onTap: () => viewModel.selectColor(color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductInfo(BagDetailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        const Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '${viewModel.category} Bag',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),

        const SizedBox(height: 16),

        // Material
        const Text(
          'Material',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          viewModel.material,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BagDetailViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed:
                  viewModel.canAddToCart
                      ? () async {
                        final success = await viewModel.addToCart();
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added to cart: ${viewModel.productName} (Size: ${viewModel.selectedSize}, Color: ${viewModel.selectedColor})',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (!success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                viewModel.errorMessage ??
                                    'Failed to add to cart',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    viewModel.canAddToCart
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child:
                  viewModel.isAddingToCart
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
                      : Text(
                        viewModel.canAddToCart
                            ? 'Add To Bag'
                            : 'Select Size & Color',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              viewModel.canAddToCart
                                  ? Colors.white
                                  : Colors.grey[600],
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
