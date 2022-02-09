import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/spotify_api/init_spotify_api.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewSpotify extends StatefulWidget {
  @override
  _WebViewSpotifyState createState() => _WebViewSpotifyState();
}

class _WebViewSpotifyState extends State<WebViewSpotify> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: AppUrl.spotifyUrlStart,
          onWebViewCreated: (WebViewController controller) {
            _controller = controller;
          },
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String s) async {
            if (s.contains(AppUrl.spotifyUrlEnd)) {
              _controller
                  ?.runJavascriptReturningResult(
                      'document.documentElement.innerText;')
                  .then((value) {
                // First decode turns \" to "
                String decoded = jsonDecode(value);
                // Second decode removes all double quotes and returns a map
                Map<String, dynamic> decodedMap = jsonDecode(decoded);
                String accessToken = decodedMap["access_token"];
                String refreshToken = decodedMap["refresh_token"];
                initSpotifyWithNewTokens(
                    user.username!, accessToken, refreshToken);
                Navigator.pushNamedAndRemoveUntil(
                    context, homepage, (Route<dynamic> route) => false);
              });
            }
          },
        ),
      ),
    );
  }
}
