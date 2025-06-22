import 'package:flutter/material.dart';
import 'package:jam/config/app_url.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/goBackDialog.dart';
import 'package:jam/util/util_functions.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotifyLogin extends StatefulWidget {
  @override
  _SpotifyLoginState createState() => _SpotifyLoginState();
}

class _SpotifyLoginState extends State<SpotifyLogin> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _didInit = false;
  late final String _initialUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;

    final user = Provider.of<UserProvider>(context, listen: false).user!;
    _initialUrl = urlQuery(AppUrl.spotifyUrlStart, {
      'user_id': user.id!,
      'api_token': user.token!,
    });

    // Create and configure the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('JAM:' + getRandomString(15))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // Hide the loading indicator
            if (_isLoading) {
              setState(() => _isLoading = false);
            }

            // Update back-navigation capability
            final canGo = await _controller.canGoBack();
            setState(() => _canGoBack = canGo);

            // Detect Spotify redirect finish
            if (url.split('?').first == AppUrl.spotifyUrlEnd) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                chatLanguages,
                    (route) => false,
              );
            }
          },
        ),
      )
      ..clearCache()
      ..loadRequest(Uri.parse(_initialUrl));

    // Clear cookies for a fresh login session
    WebViewCookieManager().clearCookies();

    _didInit = true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _canGoBack,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        // If the framework pop was handled, do nothing
        if (didPop) return;

        // Attempt WebView back navigation
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return;
        }

        // Otherwise show confirmation dialog
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) => goBackDialog(context),
        ) ??
            false;

        if (shouldExit) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Please wait while we connect you to Spotify…',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
