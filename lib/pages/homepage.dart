import 'package:flutter/material.dart';
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

    void handleThreeDotClick(String value) {
      switch (value) {
        case 'About':
          Navigator.pushNamed(context, routes.about);
          break;
        case "Contact Us":
          Navigator.pushNamed(context, routes.contactUs);
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => {
                Navigator.pushNamed(context, routes.avatar)
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/avatar.png"),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleThreeDotClick,
            itemBuilder: (BuildContext context) {
              return {"Contact Us", 'About'}.map((String choice) {
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
