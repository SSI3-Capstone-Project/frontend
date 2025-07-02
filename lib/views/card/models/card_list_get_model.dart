import 'dart:convert';

class GetOmiseCustomerCard {
  final String cardId;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  GetOmiseCustomerCard({
    required this.cardId,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory GetOmiseCustomerCard.fromJson(Map<String, dynamic> json) {
    return GetOmiseCustomerCard(
      cardId: json['card_id'],
      brand: json['brand'],
      last4: json['last4'],
      expMonth: json['exp_month'],
      expYear: json['exp_year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
