import 'dart:io'; // สำหรับ File class

class UpdatePost {
  String id;
  String title;
  String subCollectionId;
  String subDistrictId;
  String description;
  String? flaw;
  String desiredItem;
  List<PostMedia> postImages;
  List<PostMedia> postVideos;
  List<File> imageFiles; // ไฟล์รูปภาพที่จะอัปโหลด
  List<File> videoFiles; // ไฟล์วิดีโอที่จะอัปโหลด

  UpdatePost({
    required this.id,
    required this.title,
    required this.subCollectionId,
    required this.subDistrictId,
    required this.description,
    this.flaw,
    required this.desiredItem,
    required this.postImages,
    required this.postVideos,
    required this.imageFiles,
    required this.videoFiles,
  });

  factory UpdatePost.fromJson(Map<String, dynamic> json) {
    return UpdatePost(
      id: json['id'],
      title: json['title'],
      subCollectionId: json['sub_collection_id'],
      subDistrictId: json['sub_district_id'],
      description: json['description'],
      flaw: json['flaw'],
      desiredItem: json['desired_item'],
      postImages: (json['post_images'] as List)
          .map((item) => PostMedia.fromJson(item))
          .toList(),
      postVideos: (json['post_videos'] as List)
          .map((item) => PostMedia.fromJson(item))
          .toList(),
      imageFiles: [], // ต้องกำหนดค่าภายหลัง
      videoFiles: [], // ต้องกำหนดค่าภายหลัง
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sub_collection_id': subCollectionId,
      'sub_district_id': subDistrictId,
      'description': description,
      'flaw': flaw,
      'desired_item': desiredItem,
      'post_images': postImages.map((item) => item.toJson()).toList(),
      'post_videos': postVideos.map((item) => item.toJson()).toList(),
    };
  }
}

class PostMedia {
  String? id;
  int hierarchy;
  String status;

  PostMedia({
    this.id,
    required this.hierarchy,
    required this.status,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id'] as String?,
      hierarchy: json['hierarchy'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hierarchy': hierarchy,
      'status': status,
    };
  }
}
