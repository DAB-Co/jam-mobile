import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '/domain/user.dart';

class UserPreferences {
  void saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", user.email!);
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

  Future<int?> getUnreadMessageCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("unread");
  }

  Future incrementUnreadMessageCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? unread = prefs.getInt("unread");
    if (unread == null) {
      prefs.setInt("unread", 0);
    } else {
      prefs.setInt("unread", unread + 1);
    }
  }

  Future decrementUnreadMessageCount(int read) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? unread = prefs.getInt("unread");
    if (unread == null || (unread - read) < 0) {
      prefs.setInt("unread", 0);
    } else {
      prefs.setInt("unread", unread - read);
    }
  }
}
