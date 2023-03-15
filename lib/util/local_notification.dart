import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jam/pages/dm.dart';
import 'package:jam/pages/homepage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  '3131',
  'Messages',
  channelDescription: 'Messages from other jammers',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
  icon: "@mipmap/ic_launcher",
);
const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

Future initNotifications() async {
  bool notificationPermission = await Permission.notification.isGranted;
  if (!notificationPermission) {
    var askAgain = await Permission.notification.request();
    if (askAgain.isDenied) {
      await flutterLocalNotificationsPlugin.show(
        0,
        "welcome to jam",
        null,
        platformChannelSpecifics,
      );
    }
  }
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher'); // this doesn't work, there is no icon in notification
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
    String? currentRoute;
    navigatorKey.currentState?.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });
    print("current route:");
    print(currentRoute);
    if (currentRoute != null) {
      List<String> splitted = currentRoute!.split(" ");
      if (splitted.length == 2) {
        String f = splitted[0];
        String currentId = splitted[1];
        // check if already in same dm page
        if (f == "dm" && currentId == id) return;
      }
    }
    navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Homepage(
            openedNotification: true,
          ),
        ),
        (route) => false);
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: RouteSettings(name: "dm " + id),
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
