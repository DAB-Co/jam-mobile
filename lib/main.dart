import 'package:flutter/material.dart';
import 'package:jam/config/ssl.dart';
import 'package:jam/pages/messages.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/firebase.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '/domain/user.dart';
import '/pages/homepage.dart';
import '/pages/login.dart';
import '/pages/register.dart';
import '/providers/auth.dart';
import '/providers/user_provider.dart';
import '/util/shared_preference.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important!
  await loadCertificate();                   // SSL certificate
  await initNotifications();                 // Connect to firebase for notifications
  runApp(MyApp());
}

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
                      return Login();
                    var user = snapshot.data as User;
                    Provider.of<UserProvider>(context).setUser(user, context);
                    return Homepage();
                }
              }),
          routes: {
            routes.homepage: (context) => Homepage(),
            routes.login: (context) => Login(),
            routes.register: (context) => Register(),
            routes.messages: (context) => Messages(),
            // routes.dm: (context) => DM(),
          }),
    );
  }
}
