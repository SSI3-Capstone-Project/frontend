import 'dart:io'; // สำหรับ File class

class UpdateOffer {
  String id;
  String title;
  String subCollectionId;
  String description;
  String? flaw;
  List<OfferMedia> offerImages;
  List<OfferMedia> offerVideos;
  List<File> imageFiles; // ไฟล์รูปภาพที่จะอัปโหลด
  List<File> videoFiles; // ไฟล์วิดีโอที่จะอัปโหลด

  UpdateOffer({
    required this.id,
    required this.title,
    required this.subCollectionId,
    required this.description,
    this.flaw,
    required this.offerImages,
    required this.offerVideos,
    required this.imageFiles,
    required this.videoFiles,
  });

  factory UpdateOffer.fromJson(Map<String, dynamic> json) {
    return UpdateOffer(
      id: json['id'],
      title: json['title'],
      subCollectionId: json['sub_collection_id'],
      description: json['description'],
      flaw: json['flaw'],
      offerImages: (json['offer_images'] as List)
          .map((item) => OfferMedia.fromJson(item))
          .toList(),
      offerVideos: (json['offer_videos'] as List)
          .map((item) => OfferMedia.fromJson(item))
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
      'description': description,
      'flaw': flaw,
      'offer_images': offerImages.map((item) => item.toJson()).toList(),
      'offer_videos': offerVideos.map((item) => item.toJson()).toList(),
    };
  }
}

class OfferMedia {
  String? id;
  int hierarchy;
  String status;

  OfferMedia({
    this.id,
    required this.hierarchy,
    required this.status,
  });

  factory OfferMedia.fromJson(Map<String, dynamic> json) {
    return OfferMedia(
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
