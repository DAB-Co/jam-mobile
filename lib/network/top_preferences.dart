import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/profile_pic_utils.dart';
import 'package:jam/util/store_profile_hive.dart';
import 'package:jam/widgets/show_snackbar.dart';

import '../main.dart';

/// Call top_preferences from server.
/// Logs out if api token was invalid,
/// If call was successful it writes to hive box
Future topPreferencesCall(
    String userId, String apiToken, String otherId) async {
  final Map<String, String> userData = {
    "user_id": userId,
    "api_token": apiToken,
    "req_user": otherId,
  };
  try {
    var response = await post(
      Uri.parse(AppUrl.topPreferences),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(userData),
    );
    if (response.body == "Wrong api token") {
      print("wrong api token");
      logout();
      showSnackBar(navigatorKey.currentContext!, "Wrong api token");
    }
    if (response.statusCode != 200) {
      print(response);
      return;
    }
    Map<String, dynamic> decoded = jsonDecode(response.body);

    if (decoded["profile_picture"] == null) {
      // no profile picture
      deleteProfilePicture(otherId);
    } else if (userId == otherId) {
      // own profile picture
      Uint8List profilePic = Uint8List.fromList(
          json.decode(decoded["profile_picture"]).cast<int>());
      await saveBothPictures(profilePic, userId);
    } else {
      // other user's profile picture
      Uint8List profilePic = Uint8List.fromList(
          json.decode(decoded["profile_picture"]).cast<int>());
      await saveBigPicture(profilePic, otherId);
    }

    if (userId == otherId) {
      List<String> userColors = decoded["user_data"].where((element) => element["type"] == "color").map((e) => e["preference_id"]).toList().cast<String>();
      await storeColors(userId, userColors);
    } else {
      List<String> otherColors = decoded["req_user_data"].where((element) => element["type"] == "color").map((e) => e["preference_id"]).toList().cast<String>();
      await storeColors(otherId, otherColors);
    }
  } catch (err) {
    print(err);
  }
}
