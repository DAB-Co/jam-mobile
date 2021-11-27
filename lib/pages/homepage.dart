import 'package:flutter/material.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/shared_preference.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '/domain/user.dart';
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
                    padding: EdgeInsets.all(50.0),
                    child: Text(
                      user.username!,
                      style: TextStyle(
                        color: Colors.white,
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
                Navigator.pop(context);
                UserPreferences().removeUser();
                Navigator.pushReplacementNamed(context, routes.login);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 100),
          Center(
            child: Text("${greetingsText()} ${user.username!}"),
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
