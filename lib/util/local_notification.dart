import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jam/pages/dm.dart';
import '/config/routes.dart' as routes;

import '../main.dart';

var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('3131', 'Messages',
        channelDescription: 'Messages from other jammers',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

Future initNotifications() async {
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');
  final initializationSettingsIOS = IOSInitializationSettings();
  final initializationSettingsMacOS = MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: _selectNotification,
  );
}

void showNotification(String username, int id) async {
  String title = "You have messages from $username";
  String payload = id.toString() + " " + username;
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    null,
    platformChannelSpecifics,
    payload: payload,
  );
}

/// Runs when tapped on notification
Future<dynamic> _selectNotification(String? payload) async {
  var details =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  print("selected notification");
  if (details != null && payload != null) {
    // payload = id + username
    String id = payload.split(" ")[0];
    String username = payload.split(" ")[1];
    navigatorKey.currentState?.pushNamedAndRemoveUntil(routes.homepage, (route) => false);
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => DM(
          otherUsername: username,
          otherId: id,
        ),
      ),
    );
  } else {
    print("details null");
  }
}
