import 'package:flutter/material.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/util_functions.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotifyLogin extends StatefulWidget {
  @override
  _SpotifyLoginState createState() => _SpotifyLoginState();
}

class _SpotifyLoginState extends State<SpotifyLogin> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    Map<String, String> query = {
      "user_id": user.id!,
      "api_token": user.token!,
    };
    String initUrl = urlQuery(AppUrl.spotifyUrlStart, query);
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: initUrl,
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
