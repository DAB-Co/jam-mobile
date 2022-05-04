import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/block.dart';
import 'package:jam/pages/profile/profile_other.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/mqtt.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/alert.dart';
import 'package:jam/widgets/profile_picture.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DM extends StatefulWidget {
  // Constructor
  const DM({required this.otherUsername, required this.otherId}) : super();
  final String otherUsername;
  final String otherId;

  @override
  _DMState createState() =>
      _DMState(otherUsername: otherUsername, otherId: otherId);
}

class _DMState extends State<DM> with WidgetsBindingObserver {
  // Constructor
  _DMState({required this.otherUsername, required this.otherId}) : super();
  final String otherUsername;
  final String otherId;

  final chatTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    chatTextController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    Provider.of<MessageProvider>(context, listen: false).enterDM(otherId);
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void deactivate() {
    Provider.of<MessageProvider>(context, listen: false).exitDM(otherId);
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("dm resumed");
        Provider.of<MessageProvider>(context, listen: false).enterDM(otherId);
        break;
      case AppLifecycleState.inactive:
        print("dm inactive");
        break;
      case AppLifecycleState.paused:
        print("dm paused");
        Provider.of<MessageProvider>(context, listen: false).exitDM(otherId);
        break;
      case AppLifecycleState.detached:
        print("dm detached");
        Provider.of<MessageProvider>(context, listen: false).exitDM(otherId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    // for scrolling to bottom when new message arrives
    ScrollController _controller = ScrollController();
    bool firstBuild = true;

    Future<void> _animateToBottom() async {
      print("animate to bottom");
      _controller.animateTo(
        _controller.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    }

    void _send() {
      String message = chatTextController.text.trim();
      chatTextController.clear();
      if (message == "") return;
      sendMessage(otherId, message);
    }

    Future<void> _onOpen(LinkableElement link) async {
      if (await canLaunch(link.url)) {
        await launch(link.url);
      } else {
        throw 'Could not launch $link';
      }
    }

    TextButton blockButton = TextButton(
      child: Text("Block"),
      onPressed: () {
        Provider.of<MessageProvider>(context, listen: false).block(otherId);
        blockRequest(user.id!, user.token!, otherId);
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // return to list
      },
    );
    AlertDialog alertDialog = alert(
      "Do you really want to block $otherUsername?",
      blockButton,
      content: Text("You won't be able to receive messages from $otherUsername."),
    );

    void _handleThreeDotClick(String value) {
      switch (value) {
        case 'Block':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alertDialog;
            },
          );
          break;
        case 'Unblock':
          Provider.of<MessageProvider>(context, listen: false).unblock(otherId);
          unBlockRequest(user.id!, user.token!, otherId);
          Navigator.pop(context);
          break;
      }
    }

    Future boxOpening =
        Provider.of<MessageProvider>(context, listen: false).openBox(otherId);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.pinkAccent,
        title: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileOther(
                otherUsername: otherUsername,
                otherId: otherId,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                smallProfilePicture(otherId),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        otherUsername,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleThreeDotClick,
            itemBuilder: (BuildContext context) {
              Set<String> options =
                  Provider.of<MessageProvider>(context, listen: false)
                          .messages
                          .get(otherId)
                          .isBlocked
                      ? {"Unblock"}
                      : {"Block"};
              return options.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
              future: boxOpening,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    print("dm future builder waiting");
                    return Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    // Decrement unread messages with this user and scroll to bottom
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      print("post frame callback");
                      _controller.jumpTo(_controller.position.maxScrollExtent);
                      int unRead =
                          Provider.of<MessageProvider>(context, listen: false)
                              .messages
                              .get(otherId)
                              .unreadMessages;
                      Provider.of<UnreadMessageProvider>(context, listen: false)
                          .decUnreadCount(unRead);
                    });
                    return ValueListenableBuilder(
                        valueListenable: Hive.box<ChatMessage>(
                                chatBoxName(user.id!, otherId))
                            .listenable(),
                        builder: (context, Box<ChatMessage> box, widget) {
                          List<ChatMessage> messages =
                              box.values.toList().cast();
                          if (!firstBuild) {
                            // new message incoming or sent
                            _animateToBottom();
                          }
                          firstBuild = false;
                          return ListView.builder(
                            controller: _controller,
                            itemCount: messages.length,
                            //shrinkWrap: true,
                            padding: EdgeInsets.only(top: 10, bottom: 70),
                            //physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: (messages[index].isIncomingMessage
                                    ? EdgeInsets.only(
                                        left: 14,
                                        right: 60,
                                        top: 10,
                                        bottom: 10,
                                      )
                                    : EdgeInsets.only(
                                        left: 60,
                                        right: 14,
                                        top: 10,
                                        bottom: 10,
                                      )),
                                child: Align(
                                  alignment: (messages[index].isIncomingMessage
                                      ? Alignment.topLeft
                                      : Alignment.topRight),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: (messages[index].isIncomingMessage
                                          ? Colors.grey.shade200
                                          : Colors.blue[200]),
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: SelectableLinkify(
                                      text: messages[index].messageContent,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: messages[index].successful
                                            ? Colors.black
                                            : Colors.red,
                                      ),
                                      onOpen: _onOpen,
                                      options: LinkifyOptions(looseUrl: true),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        });
                }
              }),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              padding: EdgeInsets.only(left: 20, bottom: 5, top: 5, right: 5),
              //height: 60,
              width: double.infinity,
              //color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Scrollbar(
                      child: TextField(
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 6,
                        onEditingComplete: () => _send(),
                        controller: chatTextController,
                        decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                        onTap: () {
                          Timer(
                              Duration(milliseconds: 200),
                              () => _controller.jumpTo(
                                  _controller.position.maxScrollExtent));
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: FloatingActionButton(
                      onPressed: () => _send(),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.pinkAccent,
                      elevation: 0,
                      mini: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
