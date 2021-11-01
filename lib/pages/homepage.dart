import 'package:flutter/material.dart';
import 'package:jam/util/shared_preference.dart';
import 'package:provider/provider.dart';

import '/domain/user.dart';
import '/providers/user_provider.dart';
import "/util/routes.dart" as routes;

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;

    var logout = () {
      UserPreferences().removeUser();
      Navigator.pushReplacementNamed(context, routes.login);
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("DASHBOARD PAGE"),
        elevation: 0.1,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Center(child: Text(user.email!)),
          SizedBox(height: 100),
          ElevatedButton(
            onPressed: logout,
            child: Text("Logout"),
            style: ElevatedButton.styleFrom(
              primary: Colors.lightBlueAccent,
            ),
          )
        ],
      ),
    );
  }
}
