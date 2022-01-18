import 'package:flutter/material.dart';
import 'package:jam/providers/auth.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/widgets/loading.dart';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Center(
          child: Text(""),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, routes.messages);
            },
            icon: Stack(
              children: <Widget>[
                Icon(Icons.message),
                Consumer<UnreadMessageProvider>(
                  builder: (context, provider, child) {
                    int nofUnread =
                        Provider.of<UnreadMessageProvider>(context).nofUnread;
                    if (nofUnread == 0) {
                      return Text("");
                    } else {
                      return Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            nofUnread.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          )
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
                Icons.supervised_user_circle,
                color: Colors.black,
              ),
              title: const Text('Account Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              title: const Text('System Settings'),
              onTap: () {
                Navigator.pop(context);
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
          SizedBox(height: 100),
          Center(
            child: Text(user.username == null
                ? ""
                : "${greetingsText()} ${user.username!}"),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: 200.0),
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text(
                  "Time until next match: 14h 29m 21s",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
