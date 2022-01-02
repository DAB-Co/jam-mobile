import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';

/// Returns friend list from server
Future<List<String>> getFriends(String username) async {
  final Map<String, String> usernameData = {
    "username": username,
  };
  List<String> friendsList = [];
  var response;
  try {
    response = await post(
      Uri.parse(AppUrl.friends),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(usernameData),
    );
    friendsList =
    List<String>.from(jsonDecode(response.body)); // cast dynamic to string
  } catch (err) {
    print(err);
  }
  return friendsList;
}