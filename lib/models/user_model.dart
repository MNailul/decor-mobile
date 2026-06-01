import '../core/constants.dart';

class Address {
  final String label;
  final String details;

  Address({
    required this.label,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'details': details,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      label: json['label'] ?? '',
      details: json['details'] ?? '',
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String address;
  final String city;
  final List<Address> addresses;
  final String? profilePicture;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.address = '',
    this.city = '',
    required this.addresses,
    this.profilePicture,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? address,
    String? city,
    List<Address>? addresses,
    String? profilePicture,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      address: address ?? this.address,
      city: city ?? this.city,
      addresses: addresses ?? this.addresses,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'address': address,
      'city': city,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'profilePicture': profilePicture,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    String? profilePic;
    String phoneNumber = json['phone'] ?? json['phone_number'] ?? '';

    String parsedFullName = json['fullName'] ?? json['full_name'] ?? '';

    // Extract profile picture and phone from nested relationships if present
    if (json['customer'] != null) {
      profilePic = json['customer']['profile_image'];
      if (phoneNumber.isEmpty) phoneNumber = json['customer']['phone'] ?? '';
    } else if (json['seller'] != null) {
      profilePic = json['seller']['store_image'];
      if (phoneNumber.isEmpty) phoneNumber = json['seller']['phone_number'] ?? '';
      if (json['seller']['store_name'] != null && json['seller']['store_name'].toString().isNotEmpty) {
        parsedFullName = json['seller']['store_name'];
      }
    } else if (json['designer'] != null) {
      profilePic = json['designer']['designer_image'];
    }

    // Fallback to top-level if not found
    profilePic ??= json['profile_image'] ?? json['profilePicture'];

    // Ensure profilePic is a full URL if it's just a path
    if (profilePic != null && !profilePic.startsWith('http')) {
      // Use centralized storage URL
      profilePic = ApiConstants.storageUrl + profilePic;
    }

    return User(
      id: (json['id'] ?? json['user_id'] ?? '').toString(),
      fullName: parsedFullName,
      email: json['email'] ?? '',
      phone: phoneNumber,
      password: json['password'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      profilePicture: profilePic,
    );
  }
}
