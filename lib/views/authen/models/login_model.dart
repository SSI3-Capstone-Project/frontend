class LoginToken {
  final String accessToken;
  final String refreshToken;

  LoginToken({required this.accessToken, required this.refreshToken});

  factory LoginToken.fromJson(Map<String, dynamic> json) {
    return LoginToken(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}
