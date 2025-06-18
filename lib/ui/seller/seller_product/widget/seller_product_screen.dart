import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/seller/seller_product/view_model/seller_product_view_model.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_bag/seller_preview_bag/widgets/seller_previewBag_screen.dart';


class SellerProductScreen extends StatelessWidget {
  const SellerProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = SellerProductViewModel();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search your bags',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter + Add
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement filter
                  },
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  label: const Text('Filter', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push(Routes.sellerAddBag);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('+ Add Product', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            StreamBuilder(
              stream: viewModel.getProductsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Your Products', style: TextStyle(fontWeight: FontWeight.bold));
                }

                final total = snapshot.data!.docs.length;
                return Text(
                  '$total Products',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 5),

            Expanded(
              child: StreamBuilder(
                stream: viewModel.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  final products = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final data = products[index].data() as Map<String, dynamic>;

                      return InkWell(
                        onTap: () {
                          // Navigate to the preview screen for the selected product
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerPreviewBagScreen(productId: products[index].id),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: data['images'] != null && data['images'].isNotEmpty
                                  ? Image.network(
                                      data['images'][0],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, color: Colors.white),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'No Name',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('Stock: ${data['stock'] ?? '-'}'),
                                const SizedBox(height: 4),
                                Text('RM ${data['price'] ?? '-'}',
                                    style: const TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
