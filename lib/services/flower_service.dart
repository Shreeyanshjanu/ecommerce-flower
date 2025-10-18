import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flower_model.dart';

class FlowerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'flowers';

  /// Get all flowers
  Stream<List<FlowerModel>> getAllFlowers() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlowerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get flowers by category (e.g., 'yellow_flower', 'pink_flower')
  Stream<List<FlowerModel>> getFlowersByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlowerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get flowers by occasion (e.g., 'anniversary', 'birthday')
  Stream<List<FlowerModel>> getFlowersByOccasion(String occasion) {
    return _firestore
        .collection(_collectionName)
        .where('occasion', isEqualTo: occasion)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlowerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get a single flower by ID
  Future<FlowerModel?> getFlowerById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return FlowerModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting flower: $e');
      return null;
    }
  }

  /// Add a new flower (for admin use)
  Future<String?> addFlower(FlowerModel flower) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(flower.toMap());
      print('✅ Flower added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding flower: $e');
      return null;
    }
  }

  /// Update flower
  Future<bool> updateFlower(String id, FlowerModel flower) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update(flower.toMap());
      print('✅ Flower updated: $id');
      return true;
    } catch (e) {
      print('❌ Error updating flower: $e');
      return false;
    }
  }

  /// Delete flower
  Future<bool> deleteFlower(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      print('✅ Flower deleted: $id');
      return true;
    } catch (e) {
      print('❌ Error deleting flower: $e');
      return false;
    }
  }

  /// Get best deals (flowers with discount)
  Stream<List<FlowerModel>> getBestDeals() {
    return _firestore
        .collection(_collectionName)
        .where('hasDiscount', isEqualTo: true)
        .orderBy('discountPercentage', descending: true)
        .limit(8)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlowerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Search flowers by name
  Future<List<FlowerModel>> searchFlowers(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => FlowerModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error searching flowers: $e');
      return [];
    }
  }
}
