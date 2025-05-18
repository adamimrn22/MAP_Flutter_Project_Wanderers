import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/ui/core/ui/empty_appbar.dart';
import 'package:provider/provider.dart';

class CustomerHomepageScreen extends StatefulWidget {
  const CustomerHomepageScreen({super.key});

  @override
  State<CustomerHomepageScreen> createState() => _CustomerHomepageScreenState();
}

class _CustomerHomepageScreenState extends State<CustomerHomepageScreen> {
  String selectedCategory = "All Bags";
  final List<String> categories = [
    "All Bags",
    "Trendings",
    "Popular",
    "Featured",
  ];

  // Sample bag data
  final List<Map<String, dynamic>> bags = [
    {"name": "Lorem Ipsum", "price": 40.00, "image": "assets/bag.png"},
    {"name": "Lorem Ipsum", "price": 40.00, "image": "assets/bag.png"},
    {"name": "Lorem Ipsum", "price": 40.00, "image": "assets/bag.png"},
    {"name": "Lorem Ipsum", "price": 40.00, "image": "assets/bag.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final userNameFuture =
        Provider.of<AuthServices>(context, listen: false).getCurrentUserName();

    return FutureBuilder<String?>(
      future: userNameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error loading user")),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("No user found")));
        }

        final userName = snapshot.data;

        return SafeArea(
          child: Container(
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: 'Search your bags',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Hello, $userName',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(
                      'Discover your crochet',
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
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                selectedCategory = category;
                              });
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
                          onPressed: () {},
                          icon: Icon(Icons.sort),
                          label: Text('Sort'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.filter_list),
                          label: Text('Filter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: bags.length,
                      itemBuilder: (context, index) {
                        final bag = bags[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/bag.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'RM ${bag["price"].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              bag["name"],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
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
    );
  }
}
