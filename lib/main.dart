import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/pages/dashboard.dart';
import '/pages/login.dart';
import '/pages/register.dart';
import '/providers/auth.dart';
import '/providers/user_provider.dart';
import '/util/shared_preference.dart';
import 'domain/user.dart';

void main() {
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
      ],
      child: MaterialApp(
          title: 'Jam',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                print((snapshot.data as User).email);
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else if ((snapshot.data as User).email == null)
                      return Login();
                    Provider.of<UserProvider>(context)
                        .setUser(snapshot.data as User);
                    return DashBoard();
                }
              }),
          routes: {
            '/dashboard': (context) => DashBoard(),
            '/login': (context) => Login(),
            '/register': (context) => Register(),
          }),
    );
  }
}
