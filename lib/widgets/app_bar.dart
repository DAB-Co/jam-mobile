import 'package:flutter/material.dart';
import 'package:jam/config/app_url.dart';
import '../main.dart';
import '../models/user.dart';
import '../util/device_identifier.dart';
import '../util/shared_preference.dart';
import '/config/routes.dart' as routes;
import 'package:url_launcher/url_launcher.dart';


void handleThreeDotClick(String value) async {
  switch (value) {
    case 'About':
      navigatorKey.currentState?.pushNamed(routes.about);
      break;
    case 'Privacy Policy':
      final url = Uri.parse(AppUrl.privacyPolicy);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      } else {
        // Handle error appropriately
        throw 'Could not launch $url';
      }
      break;
    case 'Help Center':
      var deviceId = await getDeviceIdentifier();
      User user = await UserPreferences().getUser();
      String identifier = "${user.id}:$deviceId";
      final Uri _url = Uri.parse("mailto:dabco5317@gmail.com?subject=Jam:$identifier");

      if (!await launchUrl(_url)) {
        throw 'Could not launch $_url';
      }
  }
}

AppBar formAppBar({bool backButtonVisible: false}) {
  return AppBar(
    automaticallyImplyLeading: backButtonVisible,
    backgroundColor: Colors.pinkAccent,
    title: Text("Jam"),
    actions: <Widget>[
      PopupMenuButton<String>(
        onSelected: handleThreeDotClick,
        itemBuilder: (BuildContext context) {
          return {'About', 'Privacy Policy', 'Help Center'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),
    ],
    elevation: 0.1,
  );
}