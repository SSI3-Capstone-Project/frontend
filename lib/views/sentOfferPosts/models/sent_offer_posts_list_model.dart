class GetSentOfferPostList {
  String postId;
  String title;
  String description;
  String subCollectionName;
  String coverImageUrl;
  String username;
  String userImageUrl;

  GetSentOfferPostList({
    required this.postId,
    required this.title,
    required this.description,
    required this.subCollectionName,
    required this.coverImageUrl,
    required this.username,
    required this.userImageUrl,
  });

  factory GetSentOfferPostList.fromJson(Map<String, dynamic> json) {
    return GetSentOfferPostList(
      postId: json['post_id'] ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      subCollectionName: json['sub_collection_name'] ?? "",
      coverImageUrl: json['cover_image_url'] ?? "",
      username: json['username'] ?? "",
      userImageUrl: json['user_image_url'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'title': title,
      'description': description,
      'sub_collection_name': subCollectionName,
      'cover_image_url': coverImageUrl,
      'username': username,
      'user_image_url': userImageUrl,
    };
  }
}

class GetSentOfferPostListResponse {
  List<GetSentOfferPostList> data;
  String message;
  int status;

  GetSentOfferPostListResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory GetSentOfferPostListResponse.fromJson(Map<String, dynamic> json) {
    return GetSentOfferPostListResponse(
      data: (json['data'] as List?)
              ?.map((item) => GetSentOfferPostList.fromJson(item))
              .toList() ??
          [],
      message: json['message'] ?? "",
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
      'message': message,
      'status': status,
    };
  }
}
