class AddressModel {
  final String id;
  final String name; // Label in backend (e.g., Home, Office)
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;
  final String city;
  bool isMain;

  AddressModel({
    required this.id,
    required this.name,
    this.recipientName = '',
    this.phoneNumber = '',
    required this.fullAddress,
    this.city = '',
    this.isMain = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      name: json['label'] ?? '',
      recipientName: json['recipient_name'] ?? '', // Fallback
      phoneNumber: json['phone_number'] ?? '', // Fallback
      fullAddress: json['full_address'] ?? '',
      city: json['city'] ?? '',
      isMain: (json['is_main'] == 1 || json['is_main'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': name,
      'recipient_name': recipientName,
      'phone_number': phoneNumber,
      'full_address': fullAddress,
      'city': city,
      'is_main': isMain,
    };
  }

  AddressModel copyWith({
    String? id,
    String? name,
    String? recipientName,
    String? phoneNumber,
    String? fullAddress,
    String? city,
    bool? isMain,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      isMain: isMain ?? this.isMain,
    );
  }
}
