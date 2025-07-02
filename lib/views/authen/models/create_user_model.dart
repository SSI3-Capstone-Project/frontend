class CreateUserRequest {
  String? id;
  String username;
  String? password;
  String firstname;
  String lastname;
  String email;
  String phone;
  String gender;
  String? imageUrl;
  String bankCode;
  String bankAccountNumber;
  String bankAccountName;

  CreateUserRequest({
    this.id,
    required this.username,
    this.password,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.gender,
    this.imageUrl,
    required this.bankCode,
    required this.bankAccountNumber,
    required this.bankAccountName,
  });

  // Factory constructor for creating a new CreateUserRequest instance from a map
  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      id: json['id'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      imageUrl: json['image_url'],
      bankCode: json['bank_code'],
      bankAccountNumber: json['bank_account_number'],
      bankAccountName: json['bank_account_name'],
    );
  }

  // Convert a CreateUserRequest instance to a map to send to the API
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'image_url': imageUrl,
      'bank_code': bankCode,
      'bank_account_number': bankAccountNumber,
      'bank_account_name': bankAccountName,
    };
  }
}
