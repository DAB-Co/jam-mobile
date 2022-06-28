import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';

/// Sends message to server, returns true if server returns success message
Future<String?> sendChangePasswordRequest(String newPassword, String token) async {
  final Map<String, String> dataToSend = {
    "new_password": newPassword,
    "forgot_token": token,
  };
  try {
    var response = await post(
      Uri.parse(AppUrl.changePassword),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(dataToSend),
    );
    return response.body;
  } catch (err) {
    print(err);
    return null;
  }
}
