import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/local_notification.dart';
import 'package:jam/util/profile_pic_utils.dart';
import 'package:jam/util/time_until_match.dart';
import 'package:jam/widgets/messages_list.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '/providers/user_provider.dart';
import "/util/greetings.dart";
import '../main.dart';
import '../models/user.dart';
import 'dm.dart';

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
      }
    }

    double percent = getTimerPercentage();
    String timerText = getTimerText();
    Future _refreshTimer() async {
      setState(() {
        percent = getTimerPercentage();
        timerText = getTimerText();
      });
      Provider.of<MessageProvider>(context, listen: false).wake(user, context);
    }

    late String profilePicPath;
    // stream instead of future so that it can refresh after pop
    Stream<bool> _profilePicExists() async* {
      while (true) {
        profilePicPath = await getSmallProfilePicPath(user.id!);
        yield File(profilePicPath).existsSync();
      }
    }

    Widget profilePicture(ImageProvider img) {
      return GestureDetector(
        onTap: () => {Navigator.pushNamed(context, routes.profile)},
        child: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: img,
        ),
      );
    }

    Widget _defaultProfilePic() {
      return profilePicture(AssetImage("assets/avatar.png"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: StreamBuilder(
            stream: _profilePicExists(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return _defaultProfilePic();
                default:
                  if ((snapshot.hasError) || !(snapshot.data as bool))
                    return _defaultProfilePic();
                  else
                    return profilePicture(FileImage(File(profilePicPath)));
              }
            }),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleThreeDotClick,
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
          RefreshIndicator(
            onRefresh: _refreshTimer,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      user.username == null
                          ? ""
                          : "${greetingsText()} ${user.username!}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: const Text("Time until next match:"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: new LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 50,
                      animation: true,
                      lineHeight: 25.0,
                      animationDuration: 1000,
                      percent: percent,
                      center: Text(timerText),
                      barRadius: const Radius.circular(16),
                      progressColor: Colors.pinkAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey),
          Expanded(
            child: FutureBuilder(
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
                    {
                      // check if a notification opened this page
                      _checkForNotificationLaunch();

                      String boxName = messagesBoxName(user.id!);
                      return ValueListenableBuilder(
                          valueListenable:
                              Hive.box<ChatPair>(boxName).listenable(),
                          builder: (context, Box<ChatPair> box, widget) {
                            List<ChatPair> chats = box.values.toList().cast();
                            List<ChatPair> nonBlockedChats =
                                chats.where((c) => !c.isBlocked).toList();
                            nonBlockedChats.sort();
                            return messagesList(nonBlockedChats,
                                "There will be other people here who share the same music taste soon");
                          });
                    }
                }
              },
            ),
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

  void _checkForNotificationLaunch() async {
    var details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details == null) return;

    if (details.didNotificationLaunchApp) {
      String? payload = details.payload;
      if (payload != null) {
        // payload = id + username
        String id = payload.split(" ")[0];
        String username = payload.split(" ")[1];
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DM(
              otherUsername: username,
              otherId: id,
            ),
          ),
        );
      }
    }
  }
}
