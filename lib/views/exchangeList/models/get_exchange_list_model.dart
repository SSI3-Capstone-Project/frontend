class ExchangeListModel {
  String id;
  String postId;
  String offerId;
  String exchangeType;
  double postPriceDiff;
  double offerPriceDiff;
  DateTime createdAt;
  String postTitle;
  String offerTitle;
  String ownImageUrl;
  String otherUsername;
  String otherImageUrl;
  bool isPostOwner;
  String status;

  ExchangeListModel({
    required this.id,
    required this.postId,
    required this.offerId,
    required this.exchangeType,
    required this.postPriceDiff,
    required this.offerPriceDiff,
    required this.createdAt,
    required this.postTitle,
    required this.offerTitle,
    required this.ownImageUrl,
    required this.otherUsername,
    required this.otherImageUrl,
    required this.isPostOwner,
    required this.status,
  });

  /// **แก้ไขการป้องกันค่า `null` และ `.toDouble()`**
  factory ExchangeListModel.fromJson(Map<String, dynamic> json) {
    return ExchangeListModel(
      id: json['id'] ?? "",
      postId: json['post_id'] ?? "",
      offerId: json['offer_id'] ?? "",
      exchangeType: json['exchange_type'] ?? "",
      postPriceDiff: (json['post_price_diff'] ?? 0).toDouble(),
      offerPriceDiff: (json['offer_price_diff'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      postTitle: json['post_title'] ?? "ไม่มีข้อมูล",
      offerTitle: json['offer_title'] ?? "ไม่มีข้อมูล",
      ownImageUrl: json['own_image_url'] ?? "",
      otherUsername: json['other_username'] ?? "ไม่ระบุชื่อ",
      otherImageUrl: json['other_image_url'] ?? "",
      isPostOwner: json['is_post_owner'] ?? false,
      status: json['status'] ?? "unknown",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'offer_id': offerId,
      'exchange_type': exchangeType,
      'post_price_diff': postPriceDiff,
      'offer_price_diff': offerPriceDiff,
      'created_at': createdAt.toIso8601String(),
      'post_title': postTitle,
      'offer_title': offerTitle,
      'own_image_url': ownImageUrl,
      'other_username': otherUsername,
      'other_image_url': otherImageUrl,
      'is_post_owner': isPostOwner,
      'status': status,
    };
  }
}

class ExchangeListResponse {
  List<ExchangeListModel> data;
  String message;
  int status;

  ExchangeListResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  /// **แก้ไข: ป้องกัน `null` ใน response**
  factory ExchangeListResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeListResponse(
      data: json['data'] != null
          ? List<ExchangeListModel>.from(
              json['data'].map((x) => ExchangeListModel.fromJson(x ?? {})),
            )
          : [],
      message: json['message'] ?? "No message",
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
      'message': message,
      'status': status,
    };
  }
}
