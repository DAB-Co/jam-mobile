import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '/domain/user.dart';

class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", user.email!);
    return prefs.commit();
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    return User(
      email: email,
    );
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("email");
  }
}
