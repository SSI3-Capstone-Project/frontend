import 'dart:convert';

class GetOmiseCustomerCardDetail {
  final String cardId;
  final String brand;
  final String last4;
  final String cardHolderName;
  final int expMonth;
  final int expYear;

  GetOmiseCustomerCardDetail({
    required this.cardId,
    required this.brand,
    required this.last4,
    required this.cardHolderName,
    required this.expMonth,
    required this.expYear,
  });

  factory GetOmiseCustomerCardDetail.fromJson(Map<String, dynamic> json) {
    return GetOmiseCustomerCardDetail(
      cardId: json['card_id'],
      brand: json['brand'],
      last4: json['last4'],
      cardHolderName: json['card_holder_name'],
      expMonth: json['exp_month'],
      expYear: json['exp_year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'brand': brand,
      'last4': last4,
      'card_holder_name': cardHolderName,
      'exp_month': expMonth,
      'exp_year': expYear,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
