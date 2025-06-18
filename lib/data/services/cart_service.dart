import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/domain/model/CartItem.dart';
import 'package:mycrochetbag/domain/model/bag.dart';

class FirestoreCartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's cart collection reference
  CollectionReference _getUserCartCollection(String userId) {
    return _firestore.collection('cart').doc(userId).collection('items');
  }

  // Add item to cart
  Future<bool> addToCart(String userId, CartItem cartItem) async {
    try {
      final cartCollection = _getUserCartCollection(userId);

      // Check if item with same product, size, and color already exists
      final existingItemQuery =
          await cartCollection
              .where('productId', isEqualTo: cartItem.productId)
              .where('size', isEqualTo: cartItem.size)
              .where('color', isEqualTo: cartItem.color)
              .get();

      if (existingItemQuery.docs.isNotEmpty) {
        // Update existing item quantity
        final existingDoc = existingItemQuery.docs.first;
        final existingItem = CartItem.fromFirestore(existingDoc);

        await existingDoc.reference.update({
          'quantity': existingItem.quantity + cartItem.quantity,
          'addedAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // Add new item to cart
        await cartCollection.add(cartItem.toFirestore());
      }

      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Get all cart items for user
  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final cartCollection = _getUserCartCollection(userId);
      final querySnapshot =
          await cartCollection.orderBy('addedAt', descending: true).get();

      return querySnapshot.docs
          .map((doc) => CartItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching cart items: $e');
      return [];
    }
  }

  // Get cart items as a stream (real-time updates)
  Stream<List<CartItem>> getCartItemsStream(String userId) {
    final cartCollection = _getUserCartCollection(userId);

    return cartCollection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList(),
        );
  }

  // Update item quantity
  Future<bool> updateItemQuantity(
    String userId,
    String itemId,
    int newQuantity,
  ) async {
    try {
      final cartCollection = _getUserCartCollection(userId);

      if (newQuantity <= 0) {
        // Remove item if quantity is 0 or less
        await cartCollection.doc(itemId).delete();
      } else {
        // Update quantity
        await cartCollection.doc(itemId).update({'quantity': newQuantity});
      }

      return true;
    } catch (e) {
      print('Error updating item quantity: $e');
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String userId, String itemId) async {
    try {
      final cartCollection = _getUserCartCollection(userId);
      await cartCollection.doc(itemId).delete();
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart(String userId) async {
    try {
      final cartCollection = _getUserCartCollection(userId);
      final batch = _firestore.batch();

      final querySnapshot = await cartCollection.get();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // Get cart summary (total items and total price)
  Future<CartSummary> getCartSummary(String userId) async {
    try {
      final cartItems = await getCartItems(userId);

      int totalItems = 0;
      double totalPrice = 0.0;

      for (final item in cartItems) {
        totalItems += item.quantity;
        totalPrice += item.totalPrice;
      }

      return CartSummary(
        totalItems: totalItems,
        totalPrice: totalPrice,
        itemCount: cartItems.length,
      );
    } catch (e) {
      print('Error getting cart summary: $e');
      return CartSummary(totalItems: 0, totalPrice: 0.0, itemCount: 0);
    }
  }

  // Get cart summary as stream
  Stream<CartSummary> getCartSummaryStream(String userId) {
    return getCartItemsStream(userId).map((cartItems) {
      int totalItems = 0;
      double totalPrice = 0.0;

      for (final item in cartItems) {
        totalItems += item.quantity;
        totalPrice += item.totalPrice;
      }

      return CartSummary(
        totalItems: totalItems,
        totalPrice: totalPrice,
        itemCount: cartItems.length,
      );
    });
  }

  // Check if specific item exists in cart
  Future<bool> isItemInCart(
    String userId,
    String productId,
    String size,
    String color,
  ) async {
    try {
      final cartCollection = _getUserCartCollection(userId);
      final querySnapshot =
          await cartCollection
              .where('productId', isEqualTo: productId)
              .where('size', isEqualTo: size)
              .where('color', isEqualTo: color)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if item in cart: $e');
      return false;
    }
  }

  // Create CartItem from Bag and selections
  CartItem createCartItemFromBag(
    Bag bag,
    String size,
    String color, {
    int quantity = 1,
  }) {
    return CartItem(
      id: '', // Will be set by Firestore
      productId: bag.id,
      name: bag.name,
      price: bag.price,
      size: size,
      color: color,
      quantity: quantity,
      imageUrl: bag.imageUrls.isNotEmpty ? bag.imageUrls.first : '',
      category: bag.category,
      addedAt: DateTime.now(),
    );
  }
}

// Cart summary helper class
class CartSummary {
  final int totalItems;
  final double totalPrice;
  final int itemCount;

  CartSummary({
    required this.totalItems,
    required this.totalPrice,
    required this.itemCount,
  });

  @override
  String toString() {
    return 'CartSummary(totalItems: $totalItems, totalPrice: $totalPrice, itemCount: $itemCount)';
  }
}
