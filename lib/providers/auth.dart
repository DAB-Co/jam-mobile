import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '/domain/user.dart';
import '/util/app_url.dart';
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

    final Map<String, dynamic> loginData = {
      'username': email,
      'password': password,
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    Response response = await post(
      Uri.parse(AppUrl.login),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: json.encode(loginData),
    );

    if (response.statusCode == 200) {

      User authUser = User.fromJson(loginData);

      UserPreferences().saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': response.body
      };
    }
    return result;
  }

  Future<dynamic> register(String? email, String? password, String? passwordConfirmation) async {
    var result;

    final Map<String, String?> registrationData = {
      'username': email,
      'password': password,
    };
    Response response = await post(
        Uri.parse(AppUrl.register),
        body: json.encode(registrationData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      User authUser = User.fromJson(registrationData);

      UserPreferences().saveUser(authUser);
      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': authUser
      };
    } else {
      result = {
        'status': false,
        'message': response.body
      };
    }
    return result;
  }

}