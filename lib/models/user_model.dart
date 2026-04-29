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
  final List<Address> addresses;
  final String? profilePicture;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.addresses,
    this.profilePicture,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    List<Address>? addresses,
    String? profilePicture,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
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
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'profilePicture': profilePicture,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      profilePicture: json['profilePicture'],
    );
  }
}
