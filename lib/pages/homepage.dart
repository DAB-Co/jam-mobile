import 'package:flutter/material.dart';
import 'package:jam/providers/auth.dart';
import 'package:jam/widgets/loading.dart';
import 'package:jam/widgets/messages_list.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '../models/user.dart';
import '/providers/user_provider.dart';
import "/util/greetings.dart";

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Go back"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Log out"),
      onPressed: () {
        Provider.of<UserProvider>(context, listen: false).logout();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Attention!"),
      content: Text("Are you sure you want to log out?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    void handleThreeDotClick(String value) {
      switch (value) {
        case 'About':
          Navigator.pushNamed(context, routes.about);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Center(
          child: Text(""),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleThreeDotClick,
            itemBuilder: (BuildContext context) {
              return {'About'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        elevation: 0.1,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Important, DO NOT REMOVE
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
              ),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: AssetImage('assets/avatar.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Container(
                      width: 162,
                      height: 20,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: Text(
                          user.username == null ? "" : user.username!,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.sentiment_satisfied_alt,
                color: Colors.black,
              ),
              title: const Text('Send Feedback'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routes.contactUs);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    if (auth.loggingOutStatus == Status.LoggingOut) {
                      return loading("Logging out ... Please wait");
                    } else {
                      return alert;
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          Center(
            child: Text(user.username == null
                ? ""
                : "${greetingsText()} ${user.username!}"),
          ),
          SizedBox(height: 30),
          Divider(color: Colors.grey),
          messagesList(user.id, context),
        ],
      ),
    );
  }
}
