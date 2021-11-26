class User {
  String? email;
  String? token;

  User({this.email, this.token});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
      email: responseData['username'],
      token: responseData['token'],
    );
  }
}
