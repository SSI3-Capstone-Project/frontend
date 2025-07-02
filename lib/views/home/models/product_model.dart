import 'dart:ffi';

// product_model.dart
class Product {
  final String id;
  final String title;
  final String description;
  final String subCollectionName;
  final String coverImage;
  final String username;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.subCollectionName,
    required this.coverImage,
    required this.username,
    required this.imageUrl,
  });

  // Factory constructor to create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      subCollectionName: json['sub_collection_name'] as String,
      coverImage: json['cover_image'] as String,
      username: json['username'] as String,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}
