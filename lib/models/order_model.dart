import 'package:bloom_boom/models/cart_model.dart';
import 'package:bloom_boom/models/address_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final List<CartItem> items;
  final AddressModel deliveryAddress;
  final String deliveryDate;
  final String? specialInstructions;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String status; // pending, processing, shipped, delivered, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.deliveryDate,
    this.specialInstructions,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'userId': userId,
      'items': items.map((item) => {
        'id': item.id,
        'productName': item.productName,
        'categoryName': item.categoryName,
        'imageUrl': item.imageUrl,
        'price': item.price,
        'quantity': item.quantity,
        'subtotal': item.totalPrice,
      }).toList(),
      'deliveryAddress': {
        'id': deliveryAddress.id,
        'label': deliveryAddress.label,
        'name': deliveryAddress.name,
        'phone': deliveryAddress.phone,
        'addressLine': deliveryAddress.addressLine,
        'latitude': deliveryAddress.latitude,
        'longitude': deliveryAddress.longitude,
      },
      'deliveryDate': deliveryDate,
      'specialInstructions': specialInstructions,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from Firestore Map
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final addressData = map['deliveryAddress'] as Map<String, dynamic>;
    
    return OrderModel(
      id: id,
      orderNumber: map['orderNumber'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List).map((item) => CartItem(
        id: item['id'] ?? '',
        productName: item['productName'] ?? '',
        categoryName: item['categoryName'] ?? '',
        imageUrl: item['imageUrl'] ?? '',
        price: (item['price'] ?? 0).toDouble(),
        quantity: item['quantity'] ?? 1,
      )).toList(),
      deliveryAddress: AddressModel(
        id: addressData['id'] ?? '',
        label: addressData['label'] ?? '',
        name: addressData['name'] ?? '',
        phone: addressData['phone'] ?? '',
        addressLine: addressData['addressLine'] ?? '',
        latitude: addressData['latitude']?.toDouble(),
        longitude: addressData['longitude']?.toDouble(),
        createdAt: DateTime.now(),
      ),
      deliveryDate: map['deliveryDate'] ?? '',
      specialInstructions: map['specialInstructions'],
      paymentMethod: map['paymentMethod'] ?? '',
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Generate unique order number
  static String generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'BLM${timestamp.toString().substring(5)}';
  }
}
