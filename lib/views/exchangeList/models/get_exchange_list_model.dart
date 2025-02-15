
class ExchangeListModel {
  String id;
  String postId;
  String offerId;
  String exchangeType;
  double postPriceDiff;
  double offerPriceDiff;
  DateTime createdAt;
  String username;
  String imageUrl;

  ExchangeListModel({
    required this.id,
    required this.postId,
    required this.offerId,
    required this.exchangeType,
    required this.postPriceDiff,
    required this.offerPriceDiff,
    required this.createdAt,
    required this.username,
    required this.imageUrl,
  });

  factory ExchangeListModel.fromJson(Map<String, dynamic> json) {
    return ExchangeListModel(
      id: json['id'],
      postId: json['post_id'],
      offerId: json['offer_id'],
      exchangeType: json['exchange_type'],
      postPriceDiff: json['post_price_diff'].toDouble(),
      offerPriceDiff: json['offer_price_diff'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'],
      imageUrl: json['image_url'],
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
      'username': username,
      'image_url': imageUrl,
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

  factory ExchangeListResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeListResponse(
      data: List<ExchangeListModel>.from(json['data'].map((x) => ExchangeListModel.fromJson(x))),
      message: json['message'],
      status: json['status'],
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
