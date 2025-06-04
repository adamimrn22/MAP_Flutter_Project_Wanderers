import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_bag/seller_edit_bag/view_model/seller_editbag_view_model.dart';

class EditProductPage extends StatelessWidget {
  final Map<String, dynamic> productData;
  final String productId;

  const EditProductPage({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerEditBagViewModel(productData, productId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Product')),
        body: const _EditProductForm(),
      ),
    );
  }
}

class _EditProductForm extends StatelessWidget {
  const _EditProductForm();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SellerEditBagViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: viewModel.formKey,
        child: Column(children: [
          // Image section - show existing images and allow adding new ones
          GestureDetector(
            onTap: () => viewModel.pickImages(),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: viewModel.hasImages
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Show existing images from URLs
                        ...viewModel.existingImageUrls.map((url) => Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.network(
                                url, 
                                width: 80, 
                                height: 100, 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  Container(
                                    width: 80, 
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => viewModel.removeExistingImage(url),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )).toList(),
                        // Show new images from file picker
                        ...viewModel.newImages.map((img) => Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.file(
                                File(img.path), 
                                width: 80, 
                                height: 100, 
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => viewModel.removeNewImage(img),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )).toList(),
                      ],
                    )
                  : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.productName,
            decoration: const InputDecoration(labelText: 'Product Name'),
            onSaved: (val) => viewModel.productName = val,
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.price?.toString() ?? '',
            decoration: const InputDecoration(labelText: 'Price', prefixText: 'RM '),
            keyboardType: TextInputType.number,
            onSaved: (val) => viewModel.price = double.tryParse(val!),
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.stock?.toString() ?? '',
            decoration: const InputDecoration(labelText: 'Stock'),
            keyboardType: TextInputType.number,
            onSaved: (val) => viewModel.stock = int.tryParse(val!),
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          const Align(alignment: Alignment.centerLeft, child: Text('Sizes')),
          Wrap(
            spacing: 10,
            children: viewModel.sizes.map((size) {
              return FilterChip(
                label: Text(size),
                selected: viewModel.selectedSizes.contains(size),
                onSelected: (_) => viewModel.toggleSize(size),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: viewModel.selectedCategory,
            decoration: const InputDecoration(labelText: 'Bag Category'),
            items: viewModel.bagCategories.map((cat) =>
              DropdownMenuItem(value: cat, child: Text(cat))
            ).toList(),
            onChanged: (val) => viewModel.selectedCategory = val,
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: viewModel.selectedMaterial,
            decoration: const InputDecoration(labelText: 'Material'),
            items: viewModel.materials.map((mat) =>
              DropdownMenuItem(value: mat, child: Text(mat))
            ).toList(),
            onChanged: (val) => viewModel.selectedMaterial = val,
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.description,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
            onSaved: (val) => viewModel.description = val,
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.colors.join(', '),
            decoration: const InputDecoration(
              labelText: 'Colors',
              hintText: 'e.g., Red, Blue, Black',
            ),
            onSaved: (val) => viewModel.colors = val!.split(',').map((e) => e.trim()).toList(),
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: viewModel.isLoading ? null : () async {
              final result = await viewModel.updateProduct(context);
              if (result == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product updated successfully!')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              }
            },
            child: viewModel.isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Update'),
          ),
        ]),
      ),
    );
  }
}