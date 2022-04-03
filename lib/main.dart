import 'package:flutter/material.dart';
import 'package:jam/config/ssl.dart';
import 'package:jam/pages/kebab_menu/about.dart';
import 'package:jam/pages/profile/profile.dart';
import 'package:jam/pages/profile/blocked_users.dart';
import 'package:jam/pages/profile/chat_language.dart';
import 'package:jam/pages/kebab_menu/contact_us.dart';
import 'package:jam/pages/profile/profile_pic_selection.dart';
import 'package:jam/pages/spotify_login.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/firebase.dart';
import 'package:jam/util/local_notification.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import 'models/user.dart';
import '/pages/homepage.dart';
import 'pages/forms/login.dart';
import 'pages/forms/register.dart';
import '/providers/auth.dart';
import '/providers/user_provider.dart';
import '/util/shared_preference.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important!
  await loadCertificate(); // SSL certificate
  await initFirebase(); // Connect to firebase for notifications
  await initNotifications(); // Local notifications
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<User> getUserData() => UserPreferences().getUser();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => UnreadMessageProvider()),
      ],
      child: MaterialApp(
        title: 'Jam',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
              .copyWith(secondary: Colors.pinkAccent),
        ),
        home: FutureBuilder(
            future: getUserData(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                print((snapshot.data as User).username);
              }
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  else if ((snapshot.data as User).username == null)
                    return Register();
                  var user = snapshot.data as User;
                  Provider.of<UserProvider>(context).setUser(user, context);
                  if (user.chatLanguages == null || user.chatLanguages!.length == 0) {
                    return ChatLanguage();
                  }
                  return Homepage();
              }
            }),
        routes: {
          routes.homepage: (context) => Homepage(),
          routes.login: (context) => Login(),
          routes.register: (context) => Register(),
          routes.about: (context) => About(),
          routes.contactUs: (context) => ContactUs(),
          routes.profile: (context) => Profile(),
          routes.blockedUsers: (context) => BlockedUsers(),
          routes.spotifyLogin: (context) => SpotifyLogin(),
          routes.chatLanguages: (context) => ChatLanguage(),
          routes.profilePicSelection: (context) => ProfilePicSelection(),
        },
        navigatorKey: navigatorKey,
      ),
    );
  }
}
