import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flower_model.dart';
import '../services/flower_service.dart';

final flowerServiceProvider = Provider<FlowerService>((ref) => FlowerService());

/// Provider for all flowers
final allFlowersProvider = StreamProvider<List<FlowerModel>>((ref) {
  final service = ref.watch(flowerServiceProvider);
  return service.getAllFlowers();
});

/// Provider for flowers by category
final flowersByCategoryProvider = StreamProvider.family<List<FlowerModel>, String>((ref, category) {
  final service = ref.watch(flowerServiceProvider);
  return service.getFlowersByCategory(category);
});

/// Provider for flowers by occasion
final flowersByOccasionProvider = StreamProvider.family<List<FlowerModel>, String>((ref, occasion) {
  final service = ref.watch(flowerServiceProvider);
  return service.getFlowersByOccasion(occasion);
});

/// Provider for best deals
final bestDealsProvider = StreamProvider<List<FlowerModel>>((ref) {
  final service = ref.watch(flowerServiceProvider);
  return service.getBestDeals();
});
