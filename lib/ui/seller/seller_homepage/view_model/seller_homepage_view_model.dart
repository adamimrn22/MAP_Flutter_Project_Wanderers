// lib/ui/seller/seller_homepage/view_model/seller_homepage_view_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycrochetbag/domain/model/bag.dart';

class SellerHomepageViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Bag> _allSellerBags = [];
  List<Bag> _filteredSellerBags = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSellerDisplayName;

  String _selectedCategory = "All Bags";
  String _sortBy = "None";
  RangeValues _priceRange = const RangeValues(0, 100);
  String _searchQuery = "";

  final List<String> categories = ["All Bags", "Tote", "Sling", "Backpack"];

  SellerHomepageViewModel() {
    _initAndFetchBags();
  }

  // Getters for UI to access state
  List<Bag> get filteredSellerBags => _filteredSellerBags;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentSellerDisplayName => _currentSellerDisplayName;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  RangeValues get priceRange => _priceRange;
  String get searchQuery => _searchQuery;

  List<Bag> get allSellerBags => _allSellerBags;

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
      final user = _auth.currentUser;
      _currentSellerDisplayName =
          user?.displayName ?? user?.email?.split('@').first ?? 'Seller';

      await _fetchAllBagsFromFirestore();
      _initializePriceRange();
      _applyFilters();
    } catch (e) {
      _errorMessage = "Error initializing data or fetching bags: $e";
      print("Error initializing data or fetching bags: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAllBagsFromFirestore() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('products')
              .orderBy('createdAt', descending: true)
              .get();

      _allSellerBags =
          querySnapshot.docs.map((doc) => Bag.fromFirestore(doc)).toList();
    } catch (e) {
      _errorMessage = "Error fetching all bags from Firestore: $e";
      print("Error fetching all bags from Firestore: $e");
      _allSellerBags = [];
    }
  }

  void _initializePriceRange() {
    if (_allSellerBags.isNotEmpty) {
      double min = _allSellerBags
          .map((e) => e.price)
          .reduce((a, b) => a < b ? a : b);
      double max = _allSellerBags
          .map((e) => e.price)
          .reduce((a, b) => a > b ? a : b);

      if (min == max) {
        max = min + 1.0;
      }
      _priceRange = RangeValues(min, max);
    } else {
      _priceRange = const RangeValues(0, 100);
    }
  }

  void _applyFilters() {
    List<Bag> tempBags = List.from(_allSellerBags);

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

    _filteredSellerBags = tempBags;
    notifyListeners();
  }

  Future<void> refreshBags() async {
    await _initAndFetchBags();
  }
}
