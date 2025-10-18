class FavoriteModel {
  final String id; // productId
  final String productName;
  final String categoryName;
  final String imageUrl;
  final double price;
  final DateTime addedAt;

  FavoriteModel({
    required this.id,
    required this.productName,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'price': price,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map, String id) {
    return FavoriteModel(
      id: id,
      productName: map['productName'] ?? '',
      categoryName: map['categoryName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      addedAt: DateTime.parse(map['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
