class Address {
  final String id;
  final String fullAddress;
  final bool isDefault;

  Address({
    required this.id,
    required this.fullAddress,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      fullAddress: json['full_address'],
      isDefault: json['is_default'],
    );
  }
}
