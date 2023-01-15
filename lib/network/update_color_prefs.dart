import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/models/user.dart';

import '../providers/user_provider.dart';

/// Returns 1 if language is set successfully in server,
/// 2 if language is already in server,
/// 0 if failed
Future<int> updateColorPrefs(User user, List<String> colorsHex) async {
  Map<String, dynamic> dataToSend = {
    "user_id": user.id!,
    "api_token": user.token!,
    "preferences": colorsHex,
  };
  try {
    var response = await post(
      Uri.parse(AppUrl.updateColorPrefs),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(dataToSend),
    );
    print(response.body);
    if (response.body == "OK") {
      return 1;
    }
    if (response.body == "Wrong api token") {
      print("wrong api token in set language call");
      logout();
      return 0;
    }
    return 0;
  } catch (err) {
    print(err);
    return 0;
  }
}
