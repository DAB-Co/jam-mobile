import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jam/util/local_notification.dart';

Future initFirebase() async {
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  /*
  // Print token
  String? token = await FirebaseMessaging.instance.getToken();
  print("token:");
  print(token);
  */
  // Any time the token refreshes, print it
  FirebaseMessaging.instance.onTokenRefresh.listen(print);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  await initNotifications();

  print("Handling a background message: ${message.data}");

  String from = message.data["fromName"];
  String title = "You have messages from $from";

  showNotification(title, null);
}

Future deleteToken() async {
  await FirebaseMessaging.instance.deleteToken();
}
