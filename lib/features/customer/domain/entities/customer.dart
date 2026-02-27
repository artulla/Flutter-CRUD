/// Core domain entity — no framework dependencies
class Customer {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final bool isActive;
  final DateTime? createdAt;

  const Customer({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.isActive = true,
    this.createdAt,
  });

  Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int?,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
