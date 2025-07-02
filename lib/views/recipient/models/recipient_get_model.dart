import 'dart:convert';

class Recipient {
  final String recipientId;
  final BankAccount bankAccount;
  final String message;
  final int status;

  Recipient({
    required this.recipientId,
    required this.bankAccount,
    required this.message,
    required this.status,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      recipientId: json['data']['recipient_id'],
      bankAccount: BankAccount.fromJson(json['data']['bank_account']),
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'recipient_id': recipientId,
        'bank_account': bankAccount.toJson(),
      },
      'message': message,
      'status': status,
    };
  }
}

class BankAccount {
  final String object;
  final String? location;
  final String brand;
  final String lastDigits;
  final String name;
  final String bankCode;

  BankAccount({
    required this.object,
    this.location,
    required this.brand,
    required this.lastDigits,
    required this.name,
    required this.bankCode,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      object: json['object'],
      location: json['location'],
      brand: json['brand'],
      lastDigits: json['last_digits'],
      name: json['name'],
      bankCode: json['bank_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'location': location,
      'brand': brand,
      'last_digits': lastDigits,
      'name': name,
      'bank_code': bankCode,
    };
  }
}
