class OfferDetail {
  String id;
  String title;
  String description;
  String? flaw;
  String subCollectionName;
  String coverImage;
  String createdAt;
  List<OfferImage> offerImages;
  List<OfferVideo> offerVideos;

  OfferDetail({
    required this.id,
    required this.title,
    required this.description,
    this.flaw,
    required this.subCollectionName,
    required this.coverImage,
    required this.createdAt,
    required this.offerImages,
    required this.offerVideos,
  });

  factory OfferDetail.fromJson(Map<String, dynamic> json) {
    var offerImagesFromJson = json['offer_images'] as List?;
    List<OfferImage> offerImagesList = offerImagesFromJson != null
        ? offerImagesFromJson.map((i) => OfferImage.fromJson(i)).toList()
        : [];

    var offerVideosFromJson = json['offer_videos'] as List?;
    List<OfferVideo> offerVideosList = offerVideosFromJson != null
        ? offerVideosFromJson.map((i) => OfferVideo.fromJson(i)).toList()
        : [];

    return OfferDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      flaw: json['flaw'],
      subCollectionName: json['sub_collection_name'],
      coverImage: json['cover_image'],
      createdAt: json['created_at'],
      offerImages: offerImagesList,
      offerVideos: offerVideosList,
    );
  }
}

class OfferImage {
  String id;
  String imageUrl;
  int hierarchy;

  OfferImage({
    required this.id,
    required this.imageUrl,
    required this.hierarchy,
  });

  factory OfferImage.fromJson(Map<String, dynamic> json) {
    return OfferImage(
      id: json['id'],
      imageUrl: json['image_url'],
      hierarchy: json['hierarchy'],
    );
  }
}

class OfferVideo {
  String id;
  String videoUrl;
  int hierarchy;

  OfferVideo({
    required this.id,
    required this.videoUrl,
    required this.hierarchy,
  });

  factory OfferVideo.fromJson(Map<String, dynamic> json) {
    return OfferVideo(
      id: json['id'],
      videoUrl: json['video_url'],
      hierarchy: json['hierarchy'],
    );
  }
}
