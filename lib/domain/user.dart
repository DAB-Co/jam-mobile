class User {
  String? email;

  User({this.email});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
      email: responseData['username'],
    );
  }
}
