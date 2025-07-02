class CreateCardModel {
  final String cardId;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  CreateCardModel({
    required this.cardId,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory CreateCardModel.fromJson(Map<String, dynamic> json) {
    return CreateCardModel(
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
}

class CreateCardResponseModel {
  final CreateCardModel card;
  final String message;
  final int status;

  CreateCardResponseModel({
    required this.card,
    required this.message,
    required this.status,
  });

  factory CreateCardResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateCardResponseModel(
      card: CreateCardModel.fromJson(json['data']),
      message: json['message'],
      status: json['status'],
    );
  }
}
