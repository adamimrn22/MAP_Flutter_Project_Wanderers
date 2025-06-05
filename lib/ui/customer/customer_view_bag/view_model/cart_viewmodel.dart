import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/cart_service.dart';
import 'dart:async';

import 'package:mycrochetbag/domain/model/CartItem.dart';

class CartViewModel extends ChangeNotifier {
  final FirestoreCartService _cartService;
  final String userId;
  bool _disposed = false; // Add disposal flag

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

  // Getters with disposal check
  List<CartItem> get cartItems => _disposed ? [] : _cartItems;
  CartSummary get cartSummary =>
      _disposed
          ? CartSummary(totalItems: 0, totalPrice: 0.0, itemCount: 0)
          : _cartSummary;
  bool get isLoading => _disposed ? false : _isLoading;
  bool get isUpdating => _disposed ? false : _isUpdating;
  String? get errorMessage => _disposed ? null : _errorMessage;
  bool get isEmpty => _disposed ? true : _cartItems.isEmpty;
  int get itemCount => _disposed ? 0 : _cartItems.length;
  int get totalQuantity => _disposed ? 0 : _cartSummary.totalItems;
  double get totalPrice => _disposed ? 0.0 : _cartSummary.totalPrice;

  // Check if disposed before notifying listeners
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Initialize cart with real-time updates
  void _initializeCart() {
    if (_disposed) return;
    _subscribeToCartUpdates();
    _subscribeToCartSummary();
  }

  void _subscribeToCartUpdates() {
    if (_disposed) return;

    _cartItemsSubscription = _cartService
        .getCartItemsStream(userId)
        .listen(
          (cartItems) {
            if (_disposed) return;
            _cartItems = cartItems;
            _errorMessage = null;
            _safeNotifyListeners();
          },
          onError: (error) {
            if (_disposed) return;
            _errorMessage = 'Error loading cart: $error';
            print('Cart stream error: $error');
            _safeNotifyListeners();
          },
        );
  }

  // Subscribe to cart summary stream
  void _subscribeToCartSummary() {
    if (_disposed) return;

    _cartSummarySubscription = _cartService
        .getCartSummaryStream(userId)
        .listen(
          (summary) {
            if (_disposed) return;
            _cartSummary = summary;
            _safeNotifyListeners();
          },
          onError: (error) {
            if (_disposed) return;
            print('Cart summary stream error: $error');
          },
        );
  }

  // Load cart items manually (fallback)
  Future<void> loadCartItems() async {
    if (_disposed) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();

      final items = await _cartService.getCartItems(userId);
      final summary = await _cartService.getCartSummary(userId);

      if (_disposed) return;

      _cartItems = items;
      _cartSummary = summary;
    } catch (e) {
      if (_disposed) return;
      _errorMessage = 'Failed to load cart: $e';
      print('Error loading cart: $e');
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // Update item quantity
  Future<bool> updateItemQuantity(String itemId, int newQuantity) async {
    if (_disposed) return false;

    try {
      _isUpdating = true;
      _safeNotifyListeners();

      final success = await _cartService.updateItemQuantity(
        userId,
        itemId,
        newQuantity,
      );

      if (_disposed) return false;

      if (!success) {
        _errorMessage = 'Failed to update item quantity';
      }

      return success;
    } catch (e) {
      if (_disposed) return false;
      _errorMessage = 'Failed to update quantity: $e';
      print('Error updating quantity: $e');
      return false;
    } finally {
      if (!_disposed) {
        _isUpdating = false;
        _safeNotifyListeners();
      }
    }
  }

  // Increase item quantity
  Future<bool> increaseQuantity(String itemId) async {
    if (_disposed) return false;
    final item = _cartItems.firstWhere((item) => item.id == itemId);
    return await updateItemQuantity(itemId, item.quantity + 1);
  }

  // Decrease item quantity
  Future<bool> decreaseQuantity(String itemId) async {
    if (_disposed) return false;
    final item = _cartItems.firstWhere((item) => item.id == itemId);
    if (item.quantity <= 1) {
      return await removeItem(itemId);
    }
    return await updateItemQuantity(itemId, item.quantity - 1);
  }

  // Remove item from cart
  Future<bool> removeItem(String itemId) async {
    if (_disposed) return false;

    try {
      _isUpdating = true;
      _safeNotifyListeners();

      final success = await _cartService.removeFromCart(userId, itemId);

      if (_disposed) return false;

      if (!success) {
        _errorMessage = 'Failed to remove item';
      }

      return success;
    } catch (e) {
      if (_disposed) return false;
      _errorMessage = 'Failed to remove item: $e';
      print('Error removing item: $e');
      return false;
    } finally {
      if (!_disposed) {
        _isUpdating = false;
        _safeNotifyListeners();
      }
    }
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    if (_disposed) return false;

    try {
      _isUpdating = true;
      _safeNotifyListeners();

      final success = await _cartService.clearCart(userId);

      if (_disposed) return false;

      if (!success) {
        _errorMessage = 'Failed to clear cart';
      }

      return success;
    } catch (e) {
      if (_disposed) return false;
      _errorMessage = 'Failed to clear cart: $e';
      print('Error clearing cart: $e');
      return false;
    } finally {
      if (!_disposed) {
        _isUpdating = false;
        _safeNotifyListeners();
      }
    }
  }

  // Add item to cart
  Future<bool> addToCart(CartItem cartItem) async {
    if (_disposed) return false;

    try {
      _isUpdating = true;
      _safeNotifyListeners();

      final success = await _cartService.addToCart(userId, cartItem);

      if (_disposed) return false;

      if (!success) {
        _errorMessage = 'Failed to add item to cart';
      }

      return success;
    } catch (e) {
      if (_disposed) return false;
      _errorMessage = 'Failed to add to cart: $e';
      print('Error adding to cart: $e');
      return false;
    } finally {
      if (!_disposed) {
        _isUpdating = false;
        _safeNotifyListeners();
      }
    }
  }

  // Check if item exists in cart
  Future<bool> isItemInCart(String productId, String size, String color) async {
    if (_disposed) return false;
    return await _cartService.isItemInCart(userId, productId, size, color);
  }

  // Get item by product details
  CartItem? getCartItem(String productId, String size, String color) {
    if (_disposed) return null;
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
  String get formattedTotalPrice =>
      _disposed ? 'RM 0.00' : 'RM ${totalPrice.toStringAsFixed(2)}';

  int get totalItems => _disposed ? 0 : (_cartSummary.totalItems ?? 0);

  // Clear error message
  void clearError() {
    if (_disposed) return;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  // Refresh cart data
  Future<void> refresh() async {
    if (_disposed) return;
    await loadCartItems();
  }

  @override
  void dispose() {
    if (_disposed) return; // Prevent double disposal

    _disposed = true; // Set disposal flag first
    _cartItemsSubscription?.cancel();
    _cartSummarySubscription?.cancel();
    super.dispose();
  }
}
