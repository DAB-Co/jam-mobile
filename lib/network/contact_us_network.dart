import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/models/user.dart';

/// Sends message to server, returns true if server returns success message
Future<bool> sendContactUsRequest(User user, String? message) async {
  final Map<String, String?> dataToSend = {
    "user_id": user.id!,
    "user_token": user.token!,
    "message": message,
  };
  try {
    var response = await post(
      Uri.parse(AppUrl.suggestion),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(dataToSend),
    );
    if (response.body == "success") {
      print("successfully sent suggestion to server");
      return true;
    }
    if (response.body == "Wrong api token") {
      print("wrong api token in suggestion");
      return false;
    }
    // Map<String, dynamic> res = jsonDecode(response.body);
    return false;
  } catch (err) {
    print(err);
    return false;
  }
}
