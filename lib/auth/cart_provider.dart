import 'package:bloom_boom/models/cart_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState()) {
    _loadCartFromFirestore();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user's cart collection reference
  CollectionReference? get _userCartRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  /// Load cart from Firestore on init
  Future<void> _loadCartFromFirestore() async {
    if (_userCartRef == null) return;

    try {
      final snapshot = await _userCartRef!.get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CartItem.fromMap(data, doc.id);
      }).toList();

      state = state.copyWith(items: items);
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  /// Add item to cart (Firestore + local state)
  Future<void> addItem(CartItem item) async {
    if (_userCartRef == null) {
      print('No user logged in');
      return;
    }

    try {
      final existingIndex = state.items.indexWhere((i) => i.id == item.id);
      
      if (existingIndex >= 0) {
        // Update quantity
        final existingItem = state.items[existingIndex];
        final updatedItem = CartItem(
          id: existingItem.id,
          imageUrl: existingItem.imageUrl,
          productName: existingItem.productName,
          categoryName: existingItem.categoryName,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
        );

        // Update Firestore
        await _userCartRef!.doc(existingItem.id).update({
          'quantity': updatedItem.quantity,
        });

        // Update local state
        final updatedItems = List<CartItem>.from(state.items);
        updatedItems[existingIndex] = updatedItem;
        state = state.copyWith(items: updatedItems);
      } else {
        // Add new item
        await _userCartRef!.doc(item.id).set(item.toMap());
        state = state.copyWith(items: [...state.items, item]);
      }
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String id) async {
    if (_userCartRef == null) return;

    try {
      await _userCartRef!.doc(id).delete();
      state = state.copyWith(
        items: state.items.where((item) => item.id != id).toList(),
      );
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  /// Increase quantity
  Future<void> increaseQuantity(String id) async {
    if (_userCartRef == null) return;

    try {
      final updatedItems = state.items.map((item) {
        if (item.id == id) {
          final newItem = CartItem(
            id: item.id,
            imageUrl: item.imageUrl,
            productName: item.productName,
            categoryName: item.categoryName,
            price: item.price,
            quantity: item.quantity + 1,
          );
          
          // Update Firestore
          _userCartRef!.doc(id).update({'quantity': newItem.quantity});
          return newItem;
        }
        return item;
      }).toList();

      state = state.copyWith(items: updatedItems);
    } catch (e) {
      print('Error increasing quantity: $e');
    }
  }

  /// Decrease quantity
  Future<void> decreaseQuantity(String id) async {
    if (_userCartRef == null) return;

    try {
      final item = state.items.firstWhere((item) => item.id == id);

      if (item.quantity > 1) {
        final updatedItems = state.items.map((item) {
          if (item.id == id) {
            final newItem = CartItem(
              id: item.id,
              imageUrl: item.imageUrl,
              productName: item.productName,
              categoryName: item.categoryName,
              price: item.price,
              quantity: item.quantity - 1,
            );
            
            // Update Firestore
            _userCartRef!.doc(id).update({'quantity': newItem.quantity});
            return newItem;
          }
          return item;
        }).toList();

        state = state.copyWith(items: updatedItems);
      } else {
        removeItem(id);
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
    }
  }

  /// Add virtual money (stored per user)
  Future<void> addVirtualMoney(double amount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final newBalance = state.virtualMoney + amount;
      await _firestore.collection('users').doc(userId).set({
        'virtualMoney': newBalance,
      }, SetOptions(merge: true));

      state = state.copyWith(virtualMoney: newBalance);
    } catch (e) {
      print('Error adding money: $e');
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    if (_userCartRef == null) return;

    try {
      final snapshot = await _userCartRef!.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      state = state.copyWith(items: []);
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  /// Reload cart when user changes
  Future<void> reloadCart() async {
    state = CartState(); // Reset to default
    await _loadCartFromFirestore();
  }
}

class CartState {
  final List<CartItem> items;
  final double virtualMoney;

  CartState({
    this.items = const [],
    this.virtualMoney = 1000.0,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => items.length;

  CartState copyWith({
    List<CartItem>? items,
    double? virtualMoney,
  }) {
    return CartState(
      items: items ?? this.items,
      virtualMoney: virtualMoney ?? this.virtualMoney,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
