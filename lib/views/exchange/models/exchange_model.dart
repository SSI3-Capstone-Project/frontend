import 'dart:convert';

class ExchangeModel {
  String id;
  String postId;
  String offerId;
  String exchangeType;
  String status;
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
  PaymentDetails? paymentDetails; // nullable
  List<CardInfo>? cards; // nullable

  ExchangeModel({
    required this.id,
    required this.postId,
    required this.offerId,
    required this.exchangeType,
    required this.status,
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
    this.paymentDetails,
    this.cards,
  });

  factory ExchangeModel.fromJson(Map<String, dynamic> json) {
    return ExchangeModel(
      id: json['id'],
      postId: json['post_id'],
      offerId: json['offer_id'],
      exchangeType: json['exchange_type'],
      status: json['status'],
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
      paymentDetails: json['payment_details'] != null
          ? PaymentDetails.fromJson(json['payment_details'])
          : null,
      cards: json['cards'] != null
          ? List<CardInfo>.from(
              json['cards'].map((card) => CardInfo.fromJson(card)))
          : null,
    );
  }
}

class MeetingPoint {
  String id;
  double latitude;
  double longitude;
  String location;
  String scheduledTime;
  String? postUserCheckinTime;
  String? offerUserCheckinTime;

  MeetingPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.scheduledTime,
    this.postUserCheckinTime,
    this.offerUserCheckinTime,
  });

  factory MeetingPoint.fromJson(Map<String, dynamic> json) {
    return MeetingPoint(
      id: json['id'],
      latitude: (json['latitude']).toDouble(),
      longitude: (json['longtitude']).toDouble(),
      location: json['location'],
      scheduledTime: json['scheduled_time'],
      postUserCheckinTime: json['post_user_checkin_time'],
      offerUserCheckinTime: json['offer_user_checkin_time'],
    );
  }
}

class PaymentDetails {
  double totalAmount;
  double depositAmount;
  double? priceDiff; // nullable
  double omiseFee;
  double vat;
  double appServiceFee;

  PaymentDetails({
    required this.totalAmount,
    required this.depositAmount,
    this.priceDiff, // ทำให้ nullable
    required this.omiseFee,
    required this.vat,
    required this.appServiceFee,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      totalAmount: (json['total_amount'] as num).toDouble(),
      depositAmount: (json['deposit_amount'] as num).toDouble(),
      priceDiff: json['price_diff'] != null
          ? (json['price_diff'] as num).toDouble()
          : null, // ตรวจสอบว่า priceDiff เป็น null หรือไม่
      omiseFee: (json['omise_fee'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      appServiceFee: (json['app_service_fee'] as num).toDouble(),
    );
  }
}

class CardInfo {
  String cardId;
  String brand;
  String last4;
  int expMonth;
  int expYear;

  CardInfo({
    required this.cardId,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      cardId: json['card_id'],
      brand: json['brand'],
      last4: json['last4'],
      expMonth: json['exp_month'],
      expYear: json['exp_year'],
    );
  }
}
