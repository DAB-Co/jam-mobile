import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/models/otherUser.dart';
import 'package:jam/util/profile_pic_utils.dart';

/// Call wake API call from server.
/// If api token was invalid, return {wrong_api_token: true}
/// else friends: List<OtherUser> and refresh_token_expired: bool and was_inactive: bool
/// If there was an error, returns null
Future<Map<String, dynamic>?> wakeRequest(
    String userId, String apiToken) async {
  final Map<String, String> usernameData = {
    "user_id": userId,
    "api_token": apiToken,
  };
  List<OtherUser> friendsList = [];
  Map<String, dynamic> result = {
    "friends": friendsList,
    "was_inactive": false,
  };
  var response;
  try {
    response = await post(
      Uri.parse(AppUrl.wake),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(usernameData),
    );
    if (response.body == "Wrong api token") {
      return {"wrong_api_token": true};
    }
    Map<String, dynamic> decoded = jsonDecode(response.body);
    var smallPic = decoded["small_profile_picture"];
    if (smallPic != null) {
      Uint8List smallPicture = Uint8List.fromList(json.decode(smallPic).cast<int>());
      saveSmallPicture(smallPicture, userId);
    }

    Map<String, dynamic> rawFriends = decoded["friends"];
    result["was_inactive"] = decoded["was_inactive"];
    result["user_preferences"] = decoded["user_preferences"];
    result["available_preferences"] = decoded["available_preferences"];
    print("raw friends length:");
    print(rawFriends.length);
    for (String userId in rawFriends.keys) {
      Map<String, dynamic> cur = rawFriends[userId];
      if (cur["profile_picture_small"] != null) {
        Uint8List profilePic = Uint8List.fromList(json.decode(cur["profile_picture_small"]).cast<int>());
        saveSmallPicture(profilePic, userId);
      } else {
        deleteSmallPicture(userId);
      }
      friendsList.add(OtherUser(
        username: cur["username"],
        id: userId,
        isBlocked: cur["blocked"],
      ));
    }
  } catch (err) {
    print(err);
    return null;
  }
  return result;
}
