import 'dart:ffi';

// class Product {
//   String id;
//   String createdAt;
//   String name;
//   String profile;
//   String image;
//   String title;
//   String description;
//   String type;
//   bool isFavorated;

//   Product({
//     required this.id,
//     required this.createdAt,
//     required this.name,
//     required this.profile,
//     required this.image,
//     required this.title,
//     required this.description,
//     required this.type,
//     required this.isFavorated,
//   });

//   // ฟังก์ชันแปลง JSON เป็น Model
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       createdAt: json['createdAt'],
//       name: json['name'],
//       profile: json['profile'],
//       image: json['image'],
//       title: json['title'],
//       description: json['description'],
//       type: json['type'],
//       isFavorated: json['isFavorated'],
//     );
//   }

//   // ฟังก์ชันแปลง Model เป็น JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'createdAt': createdAt,
//       'name': name,
//       'profile': profile,
//       'image': image,
//       'title': title,
//       'description': description,
//       'type': type,
//       'isFavorated': isFavorated
//     };
//   }
// }

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