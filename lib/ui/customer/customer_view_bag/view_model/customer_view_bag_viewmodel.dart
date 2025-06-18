import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/bag_service.dart';
import 'package:mycrochetbag/data/services/cart_service.dart';
import 'package:mycrochetbag/domain/model/bag.dart';

class BagDetailViewModel extends ChangeNotifier {
  final FirestoreBagServices _bagService;
  final FirestoreCartService _cartService;
  final String userId; // User ID for cart operations

  BagDetailViewModel(this._bagService, this._cartService, this.userId);

  // State variables
  Bag? _bag;
  bool _isScreenLoading = true;
  bool _isAddingToCart = false;
  String? _selectedSize;
  String? _selectedColor;
  int _currentImageIndex = 0;
  String? _errorMessage;

  // Getters
  Bag? get bag => _bag;
  bool get isScreenLoading => _isScreenLoading;
  bool get isAddingToCart => _isAddingToCart;
  String? get selectedSize => _selectedSize;
  String? get selectedColor => _selectedColor;
  int get currentImageIndex => _currentImageIndex;
  String? get errorMessage => _errorMessage;

  // Computed properties
  bool get canAddToCart =>
      _bag != null &&
      _selectedSize != null &&
      _selectedColor != null &&
      !_isAddingToCart;

  List<String> get images => _bag?.imageUrls ?? [];
  List<String> get sizes => _bag?.sizes ?? [];
  List<String> get colors => _bag?.colors ?? [];
  String get productName => _bag?.name ?? '';
  double get price => _bag?.price ?? 0.0;
  String get description => _bag?.description ?? '';
  String get category => _bag?.category ?? '';
  String get material => _bag?.material ?? '';

  // Methods
  Future<void> loadProductDetails(String productId) async {
    try {
      _isScreenLoading = true;
      _errorMessage = null;
      notifyListeners();

      final bag = await _bagService.getProductDetails(productId);

      if (bag != null) {
        _bag = bag;
        _errorMessage = null;
      } else {
        _errorMessage = 'Product not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to load product details: $e';
      print('Error in loadProductDetails: $e');
    } finally {
      _isScreenLoading = false;
      notifyListeners();
    }
  }

  void selectSize(String size) {
    if (_selectedSize != size) {
      _selectedSize = size;
      notifyListeners();
    }
  }

  void selectColor(String color) {
    if (_selectedColor != color) {
      _selectedColor = color;
      notifyListeners();
    }
  }

  void updateImageIndex(int index) {
    if (_currentImageIndex != index) {
      _currentImageIndex = index;
      notifyListeners();
    }
  }

  Future<bool> addToCart() async {
    if (!canAddToCart) return false;

    try {
      _isAddingToCart = true;
      notifyListeners();

      // Create cart item from current bag and selections
      final cartItem = _cartService.createCartItemFromBag(
        _bag!,
        _selectedSize!,
        _selectedColor!,
        quantity: 1,
      );

      // Add to cart using the service
      final success = await _cartService.addToCart(userId, cartItem);

      if (!success) {
        _errorMessage = 'Failed to add item to cart';
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to add to cart: $e';
      print('Error adding to cart: $e');
      return false;
    } finally {
      _isAddingToCart = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset selections when product changes
  void _resetSelections() {
    _selectedSize = null;
    _selectedColor = null;
    _currentImageIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
