import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/models/otherUser.dart';

/// Call wake API call from server.
/// Returns null if api token was invalid,
/// else friends: List<OtherUser> and refresh\_token\_expired: bool,
/// If there was an error, returns friends: friendsList, refresh_token_expired: false
Future<Map<String, dynamic>?> wakeRequest(String userId, String apiToken) async {
  final Map<String, String> usernameData = {
    "user_id": userId,
    "api_token": apiToken,
  };
  List<OtherUser> friendsList = [];
  Map<String, dynamic> result = {
    "friends": friendsList,
    "refresh_token_expired": false,
  };
  var response;
  try {
    response = await post(
      Uri.parse(AppUrl.wake),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(usernameData),
    );
    if (response.body == "Wrong api token") {
      print("wrong api token");
      return null;
    }
    Map<String, dynamic> decoded = jsonDecode(response.body);
    Map<String, dynamic> rawFriends = decoded["friends"];
    result["refresh_token_expired"] = decoded["refresh_token_expired"];
    print("raw friends length:");
    print(rawFriends.length);
    for (String userId in rawFriends.keys) {
      if (!rawFriends[userId]["blocked"]) {
        friendsList.add(
            OtherUser(username: rawFriends[userId]["username"], id: userId));
      }
    }
  } catch (err) {
    print(err);
  }
  return result;
}
