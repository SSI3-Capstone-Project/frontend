import 'dart:convert';

class WishListModel {
  final String wishListId;
  final String postId;
  final String title;
  final String description;
  final String subCollectionName;
  final String coverImage;
  final String username;
  final String imageUrl;
  final DateTime createdAt;
  final String location;

  WishListModel({
    required this.wishListId,
    required this.postId,
    required this.title,
    required this.description,
    required this.subCollectionName,
    required this.coverImage,
    required this.username,
    required this.imageUrl,
    required this.createdAt,
    required this.location,
  });

  // สร้างฟังก์ชันจาก JSON
  factory WishListModel.fromJson(Map<String, dynamic> json) {
    return WishListModel(
      wishListId: json['wishList_id'] ?? '',
      postId: json['post_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subCollectionName: json['sub_collection_name'] ?? '',
      coverImage: json['cover_image'] ?? '',
      username: json['username'] ?? '',
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime(0),
      location: json['location'] ?? '',
    );
  }

  // ฟังก์ชันแปลงกลับเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'wishList_id': wishListId,
      'post_id': postId,
      'title': title,
      'description': description,
      'sub_collection_name': subCollectionName,
      'cover_image': coverImage,
      'username': username,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'location': location,
    };
  }

  // ฟังก์ชันแปลงจาก JSON string
  static List<WishListModel> fromJsonList(String str) {
    final jsonData = json.decode(str);
    return List<WishListModel>.from(
        jsonData.map((x) => WishListModel.fromJson(x)));
  }

  // ฟังก์ชันแปลงเป็น JSON string
  static String toJsonList(List<WishListModel> data) {
    final dyn = List<dynamic>.from(data.map((x) => x.toJson()));
    return json.encode(dyn);
  }
}
