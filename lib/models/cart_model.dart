class CartItem {
  final String id;
  final String imageUrl;
  final String productName;
  final String categoryName;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.imageUrl,
    required this.productName,
    required this.categoryName,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'productName': productName,
      'categoryName': categoryName,
      'price': price,
      'quantity': quantity,
    };
  }

  /// Create from Firestore Map
  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      productName: map['productName'] ?? '',
      categoryName: map['categoryName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}
