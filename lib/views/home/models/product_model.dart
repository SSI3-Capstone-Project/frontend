// import 'dart:ffi';

class Product {
  String id;
  String createdAt;
  String name;
  String profile;
  String image;
  String title;
  String description;
  String type;
  bool isFavorated;

  Product({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.profile,
    required this.image,
    required this.title,
    required this.description,
    required this.type,
    required this.isFavorated,
  });

  // ฟังก์ชันแปลง JSON เป็น Model
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      createdAt: json['createdAt'],
      name: json['name'],
      profile: json['profile'],
      image: json['image'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      isFavorated: json['isFavorated'],
    );
  }

  // ฟังก์ชันแปลง Model เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'profile': profile,
      'image': image,
      'title': title,
      'description': description,
      'type': type,
      'isFavorated': isFavorated
    };
  }
}
