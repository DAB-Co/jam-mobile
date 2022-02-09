import 'package:flutter/material.dart';
import 'package:jam/pages/web_view_spotify.dart';
import 'package:jam/spotify_api/spotify_api_calls.dart';
import 'package:jam/util/shared_preference.dart';

import '../main.dart';

initSpotify(username) async {
  String? accessToken = await UserPreferences().getSpotifyAccessToken(username);
  if (accessToken == null) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => WebViewSpotify(),
      ),
      (Route<dynamic> route) => false,
    );
  } else {
    getTopTracks();
  }
}

initSpotifyWithNewTokens(
    String username, String accessToken, String refreshToken) {
  UserPreferences().setSpotifyAccessToken(username, accessToken);
  UserPreferences().setSpotifyRefreshToken(username, refreshToken);
  getTopTracks();
}
