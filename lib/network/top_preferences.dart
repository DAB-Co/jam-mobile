import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/providers/user_provider.dart';
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
    List<String> thisUserTracks = [];
    List<String> thisUserArtists = [];
    List<String> otherUserTracks = [];
    List<String> otherUserArtists = [];
    for (dynamic i in decoded["user_data"]) {
      String name = i["name"];
      if (i["type"] == "track") {
        thisUserTracks.add(name);
      } else {
        thisUserArtists.add(name);
      }
    }
    for (dynamic i in decoded["req_user_data"]) {
      String name = i["name"];
      if (i["type"] == "track") {
        otherUserTracks.add(name);
      } else {
        otherUserArtists.add(name);
      }
    }

    List<List<String>> tracks = [thisUserTracks, otherUserTracks];
    List<String> commonTracks = tracks.fold<Set<String>>(
        tracks.first.toSet(), (a, b) => a.intersection(b.toSet())).toList();

    List<List<String>> artists = [thisUserTracks, otherUserTracks];
    List<String> commonArtists = artists.fold<Set<String>>(
        artists.first.toSet(), (a, b) => a.intersection(b.toSet())).toList();

    List<String> otherTracks = otherUserTracks.toSet().difference(commonTracks.toSet()).toList();
    List<String> otherArtists = otherUserArtists.toSet().difference(commonArtists.toSet()).toList();

    // save to hive
    String boxName = tracksArtistsBoxName(userId, otherId);
    var box;
    if (!Hive.isBoxOpen(boxName)) {
      box = await Hive.openBox<List<String>>(boxName);
    } else {
      box = Hive.box<List<String>>(boxName);
    }
    box.put("commonTracks", commonTracks);
    box.put("commonArtists", commonArtists);
    box.put("otherTracks", otherTracks);
    box.put("otherArtists", otherArtists);
  } catch (err) {
    print(err);
  }
}
