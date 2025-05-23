import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_bag/seller_add_bag/view_model/seller_addbag_view_model.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerAddBagViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Product')),
        body: const _AddProductForm(),
      ),
    );
  }
}

class _AddProductForm extends StatelessWidget {
  const _AddProductForm();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SellerAddBagViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: viewModel.formKey,
        child: Column(children: [
          GestureDetector(
            onTap: () => viewModel.pickImages(),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: viewModel.images.isEmpty
                  ? const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: viewModel.images.map((img) => Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.file(File(img.path), width: 80, height: 100, fit: BoxFit.cover),
                      )).toList(),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            decoration: const InputDecoration(labelText: 'Product Name'),
            onSaved: (val) => viewModel.productName = val,
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            decoration: const InputDecoration(labelText: 'Price', prefixText: 'RM '),
            keyboardType: TextInputType.number,
            onSaved: (val) => viewModel.price = double.tryParse(val!),
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
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
            decoration: const InputDecoration(labelText: 'Bag Category'),
            items: viewModel.bagCategories.map((cat) =>
              DropdownMenuItem(value: cat, child: Text(cat))
            ).toList(),
            onChanged: (val) => viewModel.selectedCategory = val,
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Material'),
            items: viewModel.materials.map((mat) =>
              DropdownMenuItem(value: mat, child: Text(mat))
            ).toList(),
            onChanged: (val) => viewModel.selectedMaterial = val,
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
            onSaved: (val) => viewModel.description = val,
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
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
            onPressed: () async {
              final result = await viewModel.saveProduct(context);
              if (result == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added successfully!')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              }
            },
            child: const Text('Save'),
          ),
        ]),
      ),
    );
  }
}
