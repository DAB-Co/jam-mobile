class User {
  String? username;
  String? token;

  User({this.username, this.token});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
      username: responseData["username"],
      token: responseData['token'],
    );
  }
}
