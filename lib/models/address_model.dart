class AddressModel {
  final String id;
  final String name; // e.g., Home, Office
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;
  bool isMain;

  AddressModel({
    required this.id,
    required this.name,
    required this.recipientName,
    required this.phoneNumber,
    required this.fullAddress,
    this.isMain = false,
  });

  AddressModel copyWith({
    String? id,
    String? name,
    String? recipientName,
    String? phoneNumber,
    String? fullAddress,
    bool? isMain,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      isMain: isMain ?? this.isMain,
    );
  }
}
