// lib/ui/customer/customer_homepage/view_model/customer_homepage_view_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/firebase_services.dart';

class Bag {
  final String id; // Firebase document ID
  final String name;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String? description;
  final int? stock;
  final List<String>? sizes;
  final String? material;
  final List<String>? colors;

  Bag({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls,
    required this.category,
    this.description,
    this.stock,
    this.sizes,
    this.material,
    this.colors,
  });

  factory Bag.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bag(
      id: doc.id,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      imageUrls: List<String>.from(data['images'] ?? []),
      category: data['category'] as String,
      description: data['description'] as String?,
      stock: data['stock'] as int?,
      sizes: (data['sizes'] as List?)?.map((e) => e as String).toList(),
      material: data['material'] as String?,
      colors: (data['colors'] as List?)?.map((e) => e as String).toList(),
    );
  }
}

class CustomerHomepageViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreServices _firestoreServices = FirestoreServices();

  List<Bag> _allBags = [];
  List<Bag> _filteredBags = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedCategory = "All Bags";
  String _sortBy = "None"; // 'None', 'Price: Low to High', 'Price: High to Low'
  RangeValues _priceRange = const RangeValues(0, 100);
  String _searchQuery = "";

  final List<String> categories = ["All Bags", "Tote", "Sling", "Backpack"];

  CustomerHomepageViewModel() {
    _initAndFetchBags();
  }

  // Getters for UI to access state
  List<Bag> get filteredBags => _filteredBags;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  RangeValues get priceRange => _priceRange;
  String get searchQuery => _searchQuery;

  List<Bag> get allBags => _allBags;

  // Setters for UI to update state and trigger filters
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  Future<void> _initAndFetchBags() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchAllBagsFromFirestore();
      _initializePriceRange();
      _applyFilters();
    } catch (e) {
      _errorMessage = "Error fetching bags: $e";
      print("❌ Error in CustomerHomepageViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAllBagsFromFirestore() async {
    try {
      // use FirestoreServices get product
      final querySnapshot = await _firestoreServices.getProducts().first;
      _allBags =
          querySnapshot.docs.map((doc) => Bag.fromFirestore(doc)).toList();
    } catch (e) {
      _errorMessage = "Error fetching all bags from Firestore: $e";
      print("❌ Error fetching all bags for customer: $e");
      _allBags = [];
    }
  }

  void _initializePriceRange() {
    if (_allBags.isNotEmpty) {
      double min = _allBags.map((e) => e.price).reduce((a, b) => a < b ? a : b);
      double max = _allBags.map((e) => e.price).reduce((a, b) => a > b ? a : b);

      if (min == max) {
        max = min + 1.0;
      }
      _priceRange = RangeValues(min, max);
    } else {
      _priceRange = const RangeValues(0, 100);
    }
  }

  void _applyFilters() {
    List<Bag> tempBags = List.from(_allBags);

    // 1. Filter by Category
    if (_selectedCategory != "All Bags") {
      tempBags =
          tempBags.where((bag) => bag.category == _selectedCategory).toList();
    }

    // 2. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      tempBags =
          tempBags.where((bag) {
            final nameLower = bag.name.toLowerCase();
            final queryLower = _searchQuery.toLowerCase();
            return nameLower.contains(queryLower);
          }).toList();
    }

    // 3. Filter by Price Range
    tempBags =
        tempBags.where((bag) {
          final price = bag.price;
          return price >= _priceRange.start && price <= _priceRange.end;
        }).toList();

    // 4. Sort
    if (_sortBy == "Price: Low to High") {
      tempBags.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == "Price: High to Low") {
      tempBags.sort((a, b) => b.price.compareTo(a.price));
    }

    _filteredBags = tempBags;
    notifyListeners();
  }

  Future<void> refreshBags() async {
    await _initAndFetchBags();
  }
}
