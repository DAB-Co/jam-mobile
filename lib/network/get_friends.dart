import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/models/otherUser.dart';

/// Returns friend list from server
Future<List<OtherUser>?> getFriends(String userId, String apiToken) async {
  final Map<String, String> usernameData = {
    "user_id": userId,
    "api_token": apiToken,
  };
  List<OtherUser> friendsList = [];
  var response;
  try {
    response = await post(
      Uri.parse(AppUrl.friends),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(usernameData),
    );
    if (response.body == "Wrong api token") {
      print("wrong api token");
      return null;
    }
    Map<String, dynamic> rawFriends = jsonDecode(response.body);
    for (String userId in rawFriends.keys) {
      if (!rawFriends[userId]["blocked"]) {
        friendsList.add(
            OtherUser(username: rawFriends[userId]["username"], id: userId));
      }
    }
  } catch (err) {
    print(err);
  }
  return friendsList;
}
