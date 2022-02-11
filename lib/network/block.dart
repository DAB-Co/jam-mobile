import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';

/// Returns true if server returns OK
Future<bool> blockRequest(String userId, String apiToken, String blocked) async {
  final Map<String, String> blockData = {
    "user_id": userId,
    "api_token": apiToken,
    "blocked": blocked,
  };
  var response;
  try {
    response = await post(
      Uri.parse(AppUrl.block),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(blockData),
    );
    if (response.body == "OK") {
      print("block request successful");
      return true;
    }
    else if (response.body == "Wrong api token") {
      print("wrong api token in block call");
    }
    print(response.body);
    return false;
  } catch (err) {
    print(err);
    return false;
  }
}