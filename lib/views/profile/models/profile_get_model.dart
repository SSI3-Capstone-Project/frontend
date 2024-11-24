class UserProfile {
  final String id;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String gender;
  final int rating;
  final String? imageUrl;

  UserProfile({
    required this.id,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.gender,
    required this.rating,
    this.imageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      rating: json['rating'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'rating': rating,
      'image_url': imageUrl,
    };
  }

  @override
  String toString() {
    return '''
    UserProfile {
      id: $id,
      username: $username,
      firstname: $firstname,
      lastname: $lastname,
      email: $email,
      phone: $phone,
      gender: $gender,
      rating: $rating,
      imageUrl: $imageUrl
    }
    ''';
  }
}
