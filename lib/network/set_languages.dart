import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/models/user.dart';

import '../providers/user_provider.dart';

/// Returns 1 if language is set successfully in server,
/// 2 if language is already in server,
/// 0 if failed
Future<int> setLanguages(User user, List<String> iso, bool toAdd, context) async {
  Map<String, dynamic> dataToSend = {
    "user_id": user.id!,
    "api_token": user.token!,
  };
  if (toAdd) {
    dataToSend["add_languages"] = iso;
    dataToSend["remove_languages"] = [];
  } else {
    dataToSend["add_languages"] = [];
    dataToSend["remove_languages"] = iso;
  }
  try {
    var response = await post(
      Uri.parse(AppUrl.setLanguages),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(dataToSend),
    );
    if (response.body == "OK") {
      return 1;
    }
    if (response.body == "Wrong api token") {
      print("wrong api token in set language call");
      logout();
      return 0;
    }
    if (response.statusCode == 422) {
      return 2;
    }
    return 0;
  } catch (err) {
    print(err);
    return 0;
  }
}
