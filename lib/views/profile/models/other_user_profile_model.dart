class OtherUserProfile {
  final String id;
  final String username;
  final String? imageUrl;
  final double avgRating;
  final List<OtherUserReview> reviews;

  OtherUserProfile({
    required this.id,
    required this.username,
    this.imageUrl,
    required this.avgRating,
    required this.reviews,
  });

  factory OtherUserProfile.fromJson(Map<String, dynamic> json) {
    return OtherUserProfile(
      id: json["id"],
      username: json["username"],
      imageUrl: json["image_url"],
      avgRating: (json["avg_rating"] as num).toDouble(),
      reviews: (json["reviews"] as List<dynamic>?)
              ?.map((review) => OtherUserReview.fromJson(review))
              .toList() ??
          [],
    );
  }
}

class OtherUserReview {
  final String id;
  final String reviewerId;
  final String reviewerUsername;
  final String? reviewerImageUrl;
  final double rating;
  final String reviewText;
  final String createdAt;
  final List<OtherUserReviewMedia>? reviewMedia; // อนุญาตให้เป็น null ได้

  OtherUserReview({
    required this.id,
    required this.reviewerId,
    required this.reviewerUsername,
    this.reviewerImageUrl,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    this.reviewMedia, // ไม่ต้อง required
  });

  factory OtherUserReview.fromJson(Map<String, dynamic> json) {
    return OtherUserReview(
      id: json["id"],
      reviewerId: json["reviewer_id"],
      reviewerUsername: json["reviewer_username"],
      reviewerImageUrl: json["reviewer_image_url"],
      rating: (json["rating"] as num).toDouble(),
      reviewText: json["review_text"],
      createdAt: json["created_at"],
      reviewMedia:
          (json["review_media"] as List<dynamic>?) // ตรวจสอบว่ามีค่าไหม
              ?.map((media) => OtherUserReviewMedia.fromJson(media))
              .toList(),
    );
  }
}

class OtherUserReviewMedia {
  final String id;
  final String mediaUrl;
  final String mediaType;

  OtherUserReviewMedia({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
  });

  factory OtherUserReviewMedia.fromJson(Map<String, dynamic> json) {
    return OtherUserReviewMedia(
      id: json["id"],
      mediaUrl: json["media_url"],
      mediaType: json["media_type"],
    );
  }
}
