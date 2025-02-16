import 'dart:convert';

class ExchangeModel {
  String id;
  String postId;
  String offerId;
  String exchangeType;
  double? postPriceDiff;
  double? offerPriceDiff;
  String createdAt;
  String postUsername;
  String postImageUrl;
  String offerUsername;
  String offerImageUrl;
  MeetingPoint meetingPoint;
  int exchangeStage;
  bool isOwnerPost;
  String? exchangeDate;

  ExchangeModel({
    required this.id,
    required this.postId,
    required this.offerId,
    required this.exchangeType,
    this.postPriceDiff,
    this.offerPriceDiff,
    required this.createdAt,
    required this.postUsername,
    required this.postImageUrl,
    required this.offerUsername,
    required this.offerImageUrl,
    required this.meetingPoint,
    required this.exchangeStage,
    required this.isOwnerPost,
    this.exchangeDate,
  });

  factory ExchangeModel.fromJson(Map<String, dynamic> json) {
    return ExchangeModel(
      id: json['id'],
      postId: json['post_id'],
      offerId: json['offer_id'],
      exchangeType: json['exchange_type'],
      postPriceDiff: json['post_price_diff'] != null
          ? (json['post_price_diff'] as num).toDouble()
          : null,
      offerPriceDiff: json['offer_price_diff'] != null
          ? (json['offer_price_diff'] as num).toDouble()
          : null,
      createdAt: json['created_at'],
      postUsername: json['post_username'],
      postImageUrl: json['post_image_url'],
      offerUsername: json['offer_username'],
      offerImageUrl: json['offer_image_url'],
      meetingPoint: MeetingPoint.fromJson(json['meeting_point']),
      exchangeStage: json['exchange_stage'],
      isOwnerPost: json['is_owner_post'],
      exchangeDate: json['exchange_date'],
    );
  }
}

class MeetingPoint {
  String id;
  double latitude;
  double longitude;
  String location;
  String scheduledTime;

  MeetingPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.scheduledTime,
  });

  factory MeetingPoint.fromJson(Map<String, dynamic> json) {
    return MeetingPoint(
      id: json['id'],
      latitude: (json['latitude']).toDouble(),
      longitude: (json['longtitude']).toDouble(),
      location: json['location'],
      scheduledTime: json['scheduled_time'],
    );
  }
}
