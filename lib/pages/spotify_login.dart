import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late WebViewController _controller;

  final Completer<WebViewController> _controllerCompleter =
      Completer<WebViewController>();

  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Do you want to exit?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text('Yes'),
                  ),
                ],
              ));
      return true;
    }
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    Map<String, String> query = {
      "user_id": user.id!,
      "api_token": user.token!,
    };
    String initUrl = urlQuery(AppUrl.spotifyUrlStart, query);
    return WillPopScope(
      onWillPop: () => _goBack(context),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              WebView(
                initialUrl: initUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controllerCompleter.future
                      .then((value) => _controller = value);
                  _controllerCompleter.complete(webViewController);
                },
                onPageFinished: (String s) async {
                  if (s.contains(AppUrl.spotifyUrlEnd)) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, homepage, (Route<dynamic> route) => false);
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
              isLoading
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                                "Please wait while we connect you to the spotify login page"),
                            SizedBox(height: 10),
                            CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ))
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
