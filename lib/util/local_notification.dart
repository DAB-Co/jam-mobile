import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jam/pages/dm.dart';
import 'package:jam/pages/homepage.dart';

import '../main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationDetails androidPlatformChannelSpecifics =
AndroidNotificationDetails(
  '3131',
  'Messages',
  channelDescription: 'Messages from other jammers',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
  icon: '@mipmap/ic_launcher',
);
const NotificationDetails platformChannelSpecifics =
NotificationDetails(android: androidPlatformChannelSpecifics);

Future<void> initNotifications() async {
  // Initialise the plugin. `app_icon` must be added as a drawable resource in Android project
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS & macOS initialization
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse response) async {
      _onSelectNotification(response.payload);
    },
  );
}

Future<void> showNotification(String username, int id) async {
  final title = 'You have messages from $username';
  final payload = '$id $username';
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    null,
    platformChannelSpecifics,
    payload: payload,
  );
}

/// Handles notification taps (foreground, background, or launch)
Future<void> _onSelectNotification(String? payload) async {
  final details =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (details?.didNotificationLaunchApp == true && payload != null) {
    final parts = payload.split(' ');
    final id = parts.first;
    final username = parts.sublist(1).join(' ');

    String? currentRoute;
    navigatorKey.currentState?.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });

    // If already on the same DM page, do nothing
    if (currentRoute != null) {
      final splitted = currentRoute!.split(' ');
      if (splitted.length == 2 && splitted[0] == 'dm' && splitted[1] == id) {
        return;
      }
    }

    // Navigate to home first
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Homepage(openedNotification: true),
      ),
          (route) => false,
    );

    // Then open the DM
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: RouteSettings(name: 'dm $id'),
        builder: (context) => DM(
          otherUsername: username,
          otherId: id,
        ),
      ),
    );
  }
}
