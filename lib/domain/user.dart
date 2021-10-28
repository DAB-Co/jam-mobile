class User {
  String? email;
  String? token;
  String? renewalToken;

  User({this.email, this.token, this.renewalToken});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
        email: responseData['username'],
        token: "0",
        renewalToken: "0",
    );
  }
}
