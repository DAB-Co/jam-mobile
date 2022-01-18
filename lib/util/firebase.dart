import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/util/local_notification.dart';
import 'package:jam/util/shared_preference.dart';

Future initFirebase() async {
  await Firebase.initializeApp();
  // init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ChatPairAdapter());
  Hive.registerAdapter(ChatMessageAdapter());

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
  // Print token
  String? token = await FirebaseMessaging.instance.getToken();
  print("token:");
  print(token);
  // Any time the token refreshes, print it
  FirebaseMessaging.instance.onTokenRefresh.listen(print);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  await initNotifications();

  print("Handling a background message: ${message.data}");

  User currentUser = await UserPreferences().getUser();
  if (currentUser.username == null || currentUser.id == null || currentUser.token == null) {
    print("User data missing in shared preferences, deleting notification token");
    deleteToken();
  }
  else {
    String fromId = message.data["fromId"];
    if (!Hive.isBoxOpen("${currentUser.id}:messages")) {
      await Hive.openBox<ChatPair>("${currentUser.id}:messages");
    }
    var messages = Hive.box<ChatPair>('${currentUser.id}:messages');
    print(messages);
    var person = messages.get(fromId);
    print(person);
    if (person == null) {
      print("incoming background message not in friends");
      return;
    }
    String title = "You have messages from ${person.username}";
    //Hive.close();
    showNotification(title, null);
  }
}

Future deleteToken() async {
  await FirebaseMessaging.instance.deleteToken();
}
