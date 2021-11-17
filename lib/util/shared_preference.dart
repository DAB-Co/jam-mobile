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

  Future<int?> getUnreadMessageCount(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("$username: unread");
  }

  Future incrementUnreadMessageCount(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? unread = prefs.getInt("$username: unread");
    if (unread == null) {
      prefs.setInt("$username: unread", 0);
    } else {
      prefs.setInt("$username: unread", unread + 1);
    }
  }

  Future decrementUnreadMessageCount(String username, int read) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? unread = prefs.getInt("$username: unread");
    if (unread == null || (unread - read) < 0) {
      prefs.setInt("$username: unread", 0);
    } else {
      prefs.setInt("$username: unread", unread - read);
    }
  }
}
