import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/firebase_services.dart';

class SellerPreviewBagScreen extends StatefulWidget {
  final String productId;

  const SellerPreviewBagScreen({super.key, required this.productId});

  @override
  State<SellerPreviewBagScreen> createState() => _SellerPreviewBagScreenState();
}

class _SellerPreviewBagScreenState extends State<SellerPreviewBagScreen> {
  final FirestoreServices _firestoreService = FirestoreServices();

  late PageController _pageController;
  int _currentImageIndex = 0;

  Map<String, dynamic>? _productData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchProduct();
  }

  void _fetchProduct() async {
    final doc = await FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
    if (doc.exists) {
      setState(() {
        _productData = doc.data()!;
        _loading = false;
      });
    } else {
      setState(() {
        _productData = null;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteProduct(widget.productId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_productData == null) {
      return const Scaffold(body: Center(child: Text('Product not found.')));
    }

    final images = List<String>.from(_productData!['images'] ?? []);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text('Bag Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(flex: 2),
                ],
              ),
            ),

            // Swipeable image
            if (images.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 180,
                    width: 230,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index ? Colors.amber : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              const Icon(Icons.image, size: 60, color: Colors.grey),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _info("Product Name", _productData!['name']),
                    _info("Price", 'RM ${_productData!['price']}'),
                    _info("Stock", _productData!['stock'].toString()),
                    _info("Size", (_productData!['sizes'] as List).isNotEmpty ? _productData!['sizes'][0] : '-'),
                    _info("Category", _productData!['category']),
                    _info("Material", _productData!['material']),
                    const SizedBox(height: 12),
                    const Text("Colors", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ...(_productData!['colors'] as List).map((color) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 6),
                              const SizedBox(width: 6),
                              Text(color),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),
                    const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_productData!['description']),
                  ],
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/editProduct', arguments: _productData);
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 115, 35, 29),
                      ),
                      child: const Text('Delete Product'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
