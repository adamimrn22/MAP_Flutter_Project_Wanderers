import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/cart_service.dart';
import 'dart:async';

import 'package:mycrochetbag/domain/model/CartItem.dart';

class CartViewModel extends ChangeNotifier {
  final FirestoreCartService _cartService;
  final String userId;

  CartViewModel(this._cartService, this.userId) {
    _initializeCart();
  }

  // State variables
  List<CartItem> _cartItems = [];
  CartSummary _cartSummary = CartSummary(
    totalItems: 0,
    totalPrice: 0.0,
    itemCount: 0,
  );
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  // Stream subscriptions
  StreamSubscription<List<CartItem>>? _cartItemsSubscription;
  StreamSubscription<CartSummary>? _cartSummarySubscription;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  CartSummary get cartSummary => _cartSummary;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _cartItems.isEmpty;
  int get itemCount => _cartItems.length;
  int get totalQuantity => _cartSummary.totalItems;
  double get totalPrice => _cartSummary.totalPrice;

  // Initialize cart with real-time updates
  void _initializeCart() {
    _subscribeToCartUpdates();
    _subscribeToCartSummary();
  }

  // Subscribe to cart items stream for real-time updates
  void _subscribeToCartUpdates() {
    _cartItemsSubscription = _cartService
        .getCartItemsStream(userId)
        .listen(
          (cartItems) {
            _cartItems = cartItems;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Error loading cart: $error';
            print('Cart stream error: $error');
            notifyListeners();
          },
        );
  }

  // Subscribe to cart summary stream
  void _subscribeToCartSummary() {
    _cartSummarySubscription = _cartService
        .getCartSummaryStream(userId)
        .listen(
          (summary) {
            _cartSummary = summary;
            notifyListeners();
          },
          onError: (error) {
            print('Cart summary stream error: $error');
          },
        );
  }

  // Load cart items manually (fallback)
  Future<void> loadCartItems() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final items = await _cartService.getCartItems(userId);
      final summary = await _cartService.getCartSummary(userId);

      _cartItems = items;
      _cartSummary = summary;
    } catch (e) {
      _errorMessage = 'Failed to load cart: $e';
      print('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update item quantity
  Future<bool> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      _isUpdating = true;
      notifyListeners();

      final success = await _cartService.updateItemQuantity(
        userId,
        itemId,
        newQuantity,
      );

      if (!success) {
        _errorMessage = 'Failed to update item quantity';
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to update quantity: $e';
      print('Error updating quantity: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Increase item quantity
  Future<bool> increaseQuantity(String itemId) async {
    final item = _cartItems.firstWhere((item) => item.id == itemId);
    return await updateItemQuantity(itemId, item.quantity + 1);
  }

  // Decrease item quantity
  Future<bool> decreaseQuantity(String itemId) async {
    final item = _cartItems.firstWhere((item) => item.id == itemId);
    if (item.quantity <= 1) {
      return await removeItem(itemId);
    }
    return await updateItemQuantity(itemId, item.quantity - 1);
  }

  // Remove item from cart
  Future<bool> removeItem(String itemId) async {
    try {
      _isUpdating = true;
      notifyListeners();

      final success = await _cartService.removeFromCart(userId, itemId);

      if (!success) {
        _errorMessage = 'Failed to remove item';
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to remove item: $e';
      print('Error removing item: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    try {
      _isUpdating = true;
      notifyListeners();

      final success = await _cartService.clearCart(userId);

      if (!success) {
        _errorMessage = 'Failed to clear cart';
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to clear cart: $e';
      print('Error clearing cart: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<bool> addToCart(CartItem cartItem) async {
    try {
      _isUpdating = true;
      notifyListeners();

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
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Check if item exists in cart
  Future<bool> isItemInCart(String productId, String size, String color) async {
    return await _cartService.isItemInCart(userId, productId, size, color);
  }

  // Get item by product details
  CartItem? getCartItem(String productId, String size, String color) {
    try {
      return _cartItems.firstWhere(
        (item) =>
            item.productId == productId &&
            item.size == size &&
            item.color == color,
      );
    } catch (e) {
      return null;
    }
  }

  // Get formatted total price
  String get formattedTotalPrice => 'RM ${totalPrice.toStringAsFixed(2)}';

  int get totalItems => _cartSummary.totalItems ?? 0;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh cart data
  Future<void> refresh() async {
    await loadCartItems();
  }

  @override
  void dispose() {
    _cartItemsSubscription?.cancel();
    _cartSummarySubscription?.cancel();
    super.dispose();
  }
}
