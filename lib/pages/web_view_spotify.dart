import 'package:flutter/material.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/config/routes.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewSpotify extends StatefulWidget {
  @override
  _WebViewSpotifyState createState() => _WebViewSpotifyState();
}

class _WebViewSpotifyState extends State<WebViewSpotify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: AppUrl.spotifyUrlStart,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String s) async {
            if (s.contains(AppUrl.spotifyUrlEnd)) {
              Navigator.pushNamedAndRemoveUntil(
                  context, homepage, (Route<dynamic> route) => false);
            }
          },
        ),
      ),
    );
  }
}
