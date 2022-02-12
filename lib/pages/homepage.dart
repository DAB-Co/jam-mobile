import 'package:flutter/material.dart';
import 'package:jam/pages/read_log.dart';
import 'package:jam/pages/web_view_spotify.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/local_notification.dart';
import 'package:jam/widgets/messages_list.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '/providers/user_provider.dart';
import "/util/greetings.dart";
import '../models/user.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;

    void _handleThreeDotClick(String value) {
      switch (value) {
        case 'About':
          Navigator.pushNamed(context, routes.about);
          break;
        case "Contact Us":
          Navigator.pushNamed(context, routes.contactUs);
          break;
        case "Logs":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadLog(),
            ),
          );
          break;
        case "Web":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewSpotify(),
            ),
          );
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => {Navigator.pushNamed(context, routes.avatar)},
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/avatar.png"),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleThreeDotClick,
            itemBuilder: (BuildContext context) {
              return {"Contact Us", 'About', 'Logs', 'Web'}.map((String choice) {
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
          SizedBox(height: 10),
          FutureBuilder(
            future: Provider.of<MessageProvider>(context, listen: false).init(
              Provider.of<UnreadMessageProvider>(context, listen: false),
              user,
              context,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  print("messages future builder waiting");
                  return Center(child: CircularProgressIndicator());
                default:
                  return messagesList(user, context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // discard all jam notifications
    flutterLocalNotificationsPlugin.cancelAll();
  }
}
