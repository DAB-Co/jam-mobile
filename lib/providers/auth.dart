import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jam/util/firebase.dart' as notification;

import '../config/app_url.dart';
import '/domain/user.dart';
import '/util/shared_preference.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;

  Status get registeredInStatus => _registeredInStatus;

  Future<Map<String, dynamic>> login(String? email, String? password) async {
    var result;
    var response;

    final Map<String, dynamic> loginData = {
      'email': email,
      'password': password,
      'token': notification.token,
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    try {
      response = await post(
        Uri.parse(AppUrl.login),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(loginData),
      );
    } catch (err) {
      print(err);

      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();

      return {
        'status': false,
        'message': "Error when connecting server",
      };
    }

    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body);
      User authUser = User();
      authUser.username = userData["username"];
      authUser.token = userData["api_token"];
      authUser.id = userData["user_id"].toString();

      UserPreferences().saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {
        'status': true,
        'message': 'Successful',
        'user': authUser,
      };
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {'status': false, 'message': response.body};
    }
    return result;
  }

  Future<dynamic> register(String? email, String? username, String? password) async {
    var result;
    var response;

    final Map<String, String?> registrationData = {
      'username': username,
      'email': email,
      'password': password,
      'token': notification.token,
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    try {
      response = await post(
        Uri.parse(AppUrl.register),
        body: json.encode(registrationData),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (err) {
      print(err);

      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();

      return {
        'status': false,
        'message': "Error when connecting server",
      };
    }

    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body);
      User authUser = User();
      authUser.username = username;
      authUser.token = userData["api_token"];
      authUser.id = userData["user_id"].toString();

      UserPreferences().saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {
        'status': true,
        'message': 'Successfully registered',
        'user': authUser,
      };
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {'status': false, 'message': response.body};
    }
    return result;
  }
}
