// lib/ui/customer/customer_homepage/customer_homepage_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/ui/customer/customer_homepage/home/view_model/customer_homepage_view_model.dart';
import 'package:mycrochetbag/ui/customer/customer_view_bag/customer_preview_bag_screen.dart';

class CustomerHomepageScreen extends StatelessWidget {
  const CustomerHomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerHomepageViewModel(),
      child: SafeArea(
        child: Consumer<CustomerHomepageViewModel>(
          builder: (context, viewModel, child) {
            return Scaffold(
              body: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: TextField(
                          onSubmitted: (query) {
                            viewModel.setSearchQuery(query);
                          },
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            hintText: 'Search for bags',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                            ),
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Welcome, Customer!',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: Text(
                          'Discover your next bag',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.categories.length,
                          itemBuilder: (context, index) {
                            final category = viewModel.categories[index];
                            final isSelected =
                                category == viewModel.selectedCategory;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  viewModel.setSelectedCategory(category);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                  foregroundColor:
                                      isSelected ? Colors.white : Colors.black,
                                  side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(category),
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed:
                                  () => _showSortOptions(context, viewModel),
                              icon: const Icon(Icons.sort),
                              label: const Text('Sort'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed:
                                  () => _showFilterOptions(context, viewModel),
                              icon: const Icon(Icons.filter_list),
                              label: const Text('Filter'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child:
                            viewModel.isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : viewModel.errorMessage != null
                                ? Center(
                                  child: Text(
                                    viewModel.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                                : viewModel.filteredBags.isEmpty
                                ? const Center(
                                  child: Text(
                                    "No bags found matching your criteria.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.75,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                  itemCount: viewModel.filteredBags.length,
                                  itemBuilder: (context, index) {
                                    final bag = viewModel.filteredBags[index];

                                    final imageUrl =
                                        bag.imageUrls.isNotEmpty
                                            ? bag.imageUrls.first
                                            : 'https://via.placeholder.com/150';

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    CustomerPreviewBagScreen(
                                                      productId: bag.id,
                                                    ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: Text(
                                                  'RM ${bag.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                bag.name,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSortOptions(
    BuildContext context,
    CustomerHomepageViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Sort by: None'),
              onTap: () {
                viewModel.setSortBy("None");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Sort by: Price: Low to High'),
              onTap: () {
                viewModel.setSortBy("Price: Low to High");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Sort by: Price: High to Low'),
              onTap: () {
                viewModel.setSortBy("Price: High to Low");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions(
    BuildContext context,
    CustomerHomepageViewModel viewModel,
  ) {
    double minPrice = 0;
    double maxPrice = 100;

    if (viewModel.allBags.isNotEmpty) {
      minPrice = viewModel.allBags
          .map((e) => e.price)
          .reduce((a, b) => a < b ? a : b);
      maxPrice = viewModel.allBags
          .map((e) => e.price)
          .reduce((a, b) => a > b ? a : b);

      if (minPrice == maxPrice) {
        maxPrice = minPrice + 1.0;
      }
    } else {
      minPrice = 0.0;
      maxPrice = 100.0;
    }

    RangeValues currentRange = RangeValues(
      viewModel.priceRange.start.clamp(minPrice, maxPrice),
      viewModel.priceRange.end.clamp(minPrice, maxPrice),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Price Range',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: currentRange,
                    min: minPrice,
                    max: maxPrice,
                    divisions:
                        (maxPrice - minPrice) > 0
                            ? ((maxPrice - minPrice) /
                                    (maxPrice < 100 ? 5 : 20))
                                .round()
                                .clamp(1, 100)
                            : 1,
                    labels: RangeLabels(
                      currentRange.start.round().toString(),
                      currentRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      modalSetState(() {
                        currentRange = values;
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        viewModel.setPriceRange(currentRange);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
