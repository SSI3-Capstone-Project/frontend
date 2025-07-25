import 'package:get/get_rx/src/rx_types/rx_types.dart';

class ProductDetail {
  String id;
  String title;
  String description;
  String? flaw;
  String desiredItem;
  String subCollectionName;
  String coverImage;
  String userID;
  String username;
  String userImageUrl;
  String createdAt;
  String location;
  List<ProductImage> productImages;
  List<ProductVideo> productVideos;
  RxBool isFavorated;
  String wishListId;

  ProductDetail(
      {required this.id,
      required this.title,
      required this.description,
      this.flaw,
      required this.desiredItem,
      required this.subCollectionName,
      required this.coverImage,
      required this.userID,
      required this.username,
      required this.userImageUrl,
      required this.createdAt,
      required this.location,
      required this.productImages,
      required this.productVideos,
      required bool isFavorated,
      required this.wishListId})
      : isFavorated = RxBool(isFavorated);

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    var productImagesFromJson = json['post_images'] as List?;
    List<ProductImage> productImagesList = productImagesFromJson != null
        ? productImagesFromJson.map((i) => ProductImage.fromJson(i)).toList()
        : [];

    var productVideosFromJson = json['post_videos'] as List?;
    List<ProductVideo> productVideosList = productVideosFromJson != null
        ? productVideosFromJson.map((i) => ProductVideo.fromJson(i)).toList()
        : [];

    return ProductDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      flaw: json['flaw'],
      desiredItem: json['desired_item'],
      subCollectionName: json['sub_collection_name'],
      coverImage: json['cover_image'],
      userID: json['user_id'],
      username: json['username'],
      userImageUrl: json['image_url'],
      createdAt: json['created_at'],
      location: json['location'],
      productImages: productImagesList,
      productVideos: productVideosList,
      isFavorated: json['is_favorited'],
      wishListId: json['wish_list_id'],
    );
  }
}

class ProductImage {
  String id;
  String imageUrl;
  int hierarchy;

  ProductImage({
    required this.id,
    required this.imageUrl,
    required this.hierarchy,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      imageUrl: json['image_url'],
      hierarchy: json['hierarchy'],
    );
  }
}

class ProductVideo {
  String id;
  String videoUrl;
  int hierarchy;

  ProductVideo({
    required this.id,
    required this.videoUrl,
    required this.hierarchy,
  });

  factory ProductVideo.fromJson(Map<String, dynamic> json) {
    return ProductVideo(
      id: json['id'],
      videoUrl: json['video_url'],
      hierarchy: json['hierarchy'],
    );
  }
}
