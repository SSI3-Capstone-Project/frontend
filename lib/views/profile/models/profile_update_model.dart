class UpdateProfileRequest {
  String username;
  String firstname;
  String lastname;
  String email;
  String phone;
  String gender;
  String? imageUrl;

  UpdateProfileRequest({
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.gender,
    this.imageUrl,
  });

  // สร้างจาก JSON (กรณีที่ต้องการนำข้อมูลจาก Backend มาสร้าง)
  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequest(
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      imageUrl: json['imageUrl'],
    );
  }

  // แปลงเป็น JSON เพื่อส่งข้อมูลไปยัง Backend
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return '''
    UpdateProfileRequest {
      username: $username,
      firstname: $firstname,
      lastname: $lastname,
      email: $email,
      phone: $phone,
      gender: $gender,
      imageUrl: $imageUrl
    }
    ''';
  }
}
