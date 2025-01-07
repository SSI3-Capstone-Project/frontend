class WishListDetail {
  final String wishListId;
  final String postId;
  final String userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  WishListDetail({
    required this.wishListId,
    required this.postId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WishListDetail.fromJson(Map<String, dynamic> json) {
    return WishListDetail(
      wishListId: json['wishList_id'],
      postId: json['post_id'],
      userId: json['user_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishList_id': wishListId,
      'post_id': postId,
      'user_id': userId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '''
    WishListDetail {
      wishListId: $wishListId,
      postId: $postId,
      userId: $userId,
      status: $status,
      createdAt: $createdAt,
      updatedAt: $updatedAt
    }
    ''';
  }
}
