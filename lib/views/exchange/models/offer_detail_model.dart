class OfferDetail {
  String id;
  String username;
  String userImage;
  String title;
  String description;
  String? flaw;
  // String subCollectionName;
  // String location;
  // String coverImage;
  // String createdAt;
  List<OfferImage> offerImages;
  List<OfferVideo> offerVideos;

  OfferDetail({
    required this.id,
    required this.username,
    required this.userImage,
    required this.title,
    required this.description,
    this.flaw,
    // required this.subCollectionName,
    // required this.location,
    // required this.coverImage,
    // required this.createdAt,
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
      id: json['offer_id'],
      username: json['offer_username'],
      userImage: json['offer_user_image_url'],
      title: json['offer_title'],
      description: json['offer_description'],
      flaw: json['offer_flaw'],
      // subCollectionName: json['sub_collection_name'],
      // location: json['location'],
      // coverImage: json['cover_image'],
      // createdAt: json['created_at'],
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
