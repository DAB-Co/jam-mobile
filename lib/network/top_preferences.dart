import 'dart:convert';

import 'package:http/http.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/models/artist_model.dart';
import 'package:jam/models/track_model.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/store_tracks_artists_hive.dart';
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

    List<dynamic> thisUser = separateArtistAndTrack(decoded["user_data"]);
    List<Track> thisUserTracks = thisUser[0];
    List<Artist> thisUserArtists = thisUser[1];

    List<dynamic> otherUser = separateArtistAndTrack(decoded["req_user_data"]);
    List<Track> otherUserTracks = otherUser[0];
    List<Artist> otherUserArtists = otherUser[1];

    print(otherUserArtists);
    print(otherUserTracks);

    List<List<Track>> tracks = [thisUserTracks, otherUserTracks];
    List<Track> commonTracks = tracks
        .fold<Set<Track>>(
            tracks.first.toSet(), (a, b) => a.intersection(b.toSet()))
        .toList();

    List<List<Artist>> artists = [thisUserArtists, otherUserArtists];
    List<Artist> commonArtists = artists
        .fold<Set<Artist>>(
            artists.first.toSet(), (a, b) => a.intersection(b.toSet()))
        .toList();

    List<Track> otherTracks =
        otherUserTracks.toSet().difference(commonTracks.toSet()).toList();
    List<Artist> otherArtists =
        otherUserArtists.toSet().difference(commonArtists.toSet()).toList();

    print(commonArtists);
    print(otherTracks);
    print(otherArtists);

    // save to hive
    await storeTracksAndArtists(userId, otherId, commonTracks, otherTracks,
        commonArtists, otherArtists);
  } catch (err) {
    print(err);
  }
}

/// [tracks, artists]
List<List> separateArtistAndTrack(l) {
  List<Track> tracks = [];
  List<Artist> artists = [];
  for (dynamic i in l) {
    String name = i["name"];
    var data = jsonDecode(i["raw_data"]);
    if (i["type"] == "track") {
      Track cur = Track(
        name: name,
        imageUrl: data["album"]["images"][2]["url"],
        spotifyUrl: data["external_urls"]["spotify"],
        albumName: data["album"]["name"],
        artist: data["album"]["artists"][0]["name"],
      );
      tracks.add(cur);
    } else {
      Artist cur = Artist(
        name: name,
        imageUrl: data["images"][2]["url"],
        spotifyUrl: data["external_urls"]["spotify"],
        genre: data["genres"].join(', '),
      );
      artists.add(cur);
    }
  }
  return [tracks, artists];
}