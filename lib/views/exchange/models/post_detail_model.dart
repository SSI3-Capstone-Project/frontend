class PostDetail {
  String id;
  String username;
  String userImage;
  String title;
  String description;
  String? flaw;
  // String desiredItem;
  // String subCollectionName;
  // String location;
  // String coverImage;
  // String createdAt;
  List<PostImage> postImages;
  List<PostVideo> postVideos;

  PostDetail({
    required this.id,
    required this.username,
    required this.userImage,
    required this.title,
    required this.description,
    this.flaw,
    // required this.desiredItem,
    // required this.subCollectionName,
    // required this.location,
    // required this.coverImage,
    // required this.createdAt,
    required this.postImages,
    required this.postVideos,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    var postImagesFromJson = json['post_images'] as List?;
    List<PostImage> postImagesList = postImagesFromJson != null
        ? postImagesFromJson.map((i) => PostImage.fromJson(i)).toList()
        : [];

    var postVideosFromJson = json['post_videos'] as List?;
    List<PostVideo> postVideosList = postVideosFromJson != null
        ? postVideosFromJson.map((i) => PostVideo.fromJson(i)).toList()
        : [];

    return PostDetail(
      id: json['post_id'],
      username: json['post_username'],
      userImage: json['post_user_image_url'],
      title: json['post_title'],
      description: json['post_description'],
      flaw: json['post_flaw'],
      // desiredItem: json['desired_item'],
      // subCollectionName: json['sub_collection_name'],
      // location: json['location'],
      // coverImage: json['cover_image'],
      // createdAt: json['created_at'],
      postImages: postImagesList,
      postVideos: postVideosList,
    );
  }
}

class PostImage {
  String id;
  String imageUrl;
  int hierarchy;

  PostImage({
    required this.id,
    required this.imageUrl,
    required this.hierarchy,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      id: json['id'],
      imageUrl: json['image_url'],
      hierarchy: json['hierarchy'],
    );
  }
}

class PostVideo {
  String id;
  String videoUrl;
  int hierarchy;

  PostVideo({
    required this.id,
    required this.videoUrl,
    required this.hierarchy,
  });

  factory PostVideo.fromJson(Map<String, dynamic> json) {
    return PostVideo(
      id: json['id'],
      videoUrl: json['video_url'],
      hierarchy: json['hierarchy'],
    );
  }
}
