import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jam/providers/mqtt.dart';
import 'package:jam/util/e2e.dart';

import '../models/user.dart';
import '/util/shared_preference.dart';
import '../config/app_url.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut,
  LoggingOut,
}

/// API calls regarding auth
class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;
  Status _loggingOutStatus = Status.LoggedIn;

  Status get loggedInStatus => _loggedInStatus;

  Status get registeredInStatus => _registeredInStatus;

  Status get loggingOutStatus => _loggingOutStatus;

  Future<Map<String, dynamic>> login(String? email, String? password) async {
    var result;
    var response;

    final Map<String, dynamic> loginData = {
      'email': email,
      'password': password,
      'notification_token': await FirebaseMessaging.instance.getToken(),
      "device_id": await getDeviceIdentifier(),
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
      authUser.chatLanguages = userData["languages"].map((iso)=>iso.toLowerCase()).toList();

      UserPreferences().saveUser(authUser);
      initializeEncryption();

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {
        'status': true,
        'message': 'Successful',
        'user': authUser,
        "was_inactive": userData["was_inactive"],
      };
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {'status': false, 'message': response.body};
    }
    return result;
  }

  Future<dynamic> register(
      String? email, String? username, String? password) async {
    var result;
    var response;

    final Map<String, String?> registrationData = {
      'username': username,
      'email': email,
      'password': password,
      'notification_token': await FirebaseMessaging.instance.getToken(),
      "device_id": await getDeviceIdentifier(),
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
      initializeEncryption();

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
