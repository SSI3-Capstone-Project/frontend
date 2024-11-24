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
    };
  }
}
