import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jam/config/app_url.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewSpotify extends StatefulWidget {
  @override
  _WebViewSpotifyState createState() => _WebViewSpotifyState();
}

class _WebViewSpotifyState extends State<WebViewSpotify> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: AppUrl.spotifyUrlStart,
        onWebViewCreated: (WebViewController controller) {
          _controller = controller;
        },
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (String s) async {
          print(s);
          if (s == AppUrl.spotifyUrlEnd) {
            print("endd");
            _controller?.runJavascriptReturningResult('document.documentElement.innerText.trim();').then((value) {
              print(value);
              var decoded = jsonDecode(value);
              print(decoded);
              var decoded2 = jsonDecode(decoded);
              print(decoded2);
              print(decoded2["cookie_status"]);
            });
          }
        },
      ),
    );
  }
}
