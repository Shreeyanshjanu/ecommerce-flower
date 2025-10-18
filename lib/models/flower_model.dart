class FlowerModel {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., 'yellow_flower', 'pink_flower'
  final String occasion; // e.g., 'anniversary', 'birthday', or empty for regular
  final String imageUrl; // Firebase Storage URL
  final double price;
  final double rating;
  final String weight;
  final bool hasDiscount;
  final int discountPercentage;
  final bool isInStock;
  final DateTime createdAt;

  FlowerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.occasion = '',
    required this.imageUrl,
    required this.price,
    this.rating = 4.5,
    this.weight = '1 Kg',
    this.hasDiscount = false,
    this.discountPercentage = 0,
    this.isInStock = true,
    required this.createdAt,
  });

  /// Convert Firestore document to FlowerModel
  factory FlowerModel.fromMap(Map<String, dynamic> data, String id) {
    return FlowerModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      occasion: data['occasion'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 100).toDouble(),
      rating: (data['rating'] ?? 4.5).toDouble(),
      weight: data['weight'] ?? '1 Kg',
      hasDiscount: data['hasDiscount'] ?? false,
      discountPercentage: data['discountPercentage'] ?? 0,
      isInStock: data['isInStock'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  /// Convert FlowerModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'occasion': occasion,
      'imageUrl': imageUrl,
      'price': price,
      'rating': rating,
      'weight': weight,
      'hasDiscount': hasDiscount,
      'discountPercentage': discountPercentage,
      'isInStock': isInStock,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Copy with method for easy updates
  FlowerModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? occasion,
    String? imageUrl,
    double? price,
    double? rating,
    String? weight,
    bool? hasDiscount,
    int? discountPercentage,
    bool? isInStock,
    DateTime? createdAt,
  }) {
    return FlowerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      occasion: occasion ?? this.occasion,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      weight: weight ?? this.weight,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isInStock: isInStock ?? this.isInStock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
