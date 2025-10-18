import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/favorite_model.dart';

class FavoriteNotifier extends StateNotifier<List<FavoriteModel>> {
  FavoriteNotifier() : super([]);
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> loadFavorites() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();
    state = snapshot.docs
        .map((doc) => FavoriteModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> toggleFavorite(FavoriteModel fav) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(fav.id);
    final exists = state.any((f) => f.id == fav.id);
    if (exists) {
      await docRef.delete();
      state = state.where((f) => f.id != fav.id).toList();
    } else {
      await docRef.set(fav.toMap());
      state = [fav, ...state];
    }
  }

  bool isFavorite(String productId) {
    return state.any((f) => f.id == productId);
  }

  Future<void> removeFavorite(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .delete();
    state = state.where((f) => f.id != productId).toList();
  }

  Future<void> clearFavorites() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestore.batch();
    for (final fav in state) {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(fav.id);
      batch.delete(docRef);
    }
    await batch.commit();
    state = [];
  }
}

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<FavoriteModel>>(
  (ref) => FavoriteNotifier(),
);
