class AddressModel {
  final String id;
  final String label;
  final String name;
  final String phone;
  final String addressLine;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.addressLine,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'name': name,
      'phone': phone,
      'addressLine': addressLine,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map, String id) {
    return AddressModel(
      id: id,
      label: map['label'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      addressLine: map['addressLine'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      isDefault: map['isDefault'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
