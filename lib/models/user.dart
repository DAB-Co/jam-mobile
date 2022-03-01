class User {
  String? username;
  String? token;
  String? id;
  /// iso codes of chat languages
  List<dynamic>? chatLanguages;

  User({this.username, this.token, this.id});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
      username: responseData["username"],
      token: responseData['token'],
      id: responseData["user_id"],
    );
  }
}
