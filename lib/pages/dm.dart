import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:jam/providers/mqtt.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/util_functions.dart';
import 'package:provider/provider.dart';

class DM extends StatefulWidget {
  // Constructor
  const DM({required this.otherUsername, required this.otherId}) : super();
  final String otherUsername;
  final String otherId;

  @override
  _DMState createState() =>
      _DMState(otherUsername: otherUsername, otherId: otherId);
}

class _DMState extends State<DM> {
  // Constructor
  _DMState({required this.otherUsername, required this.otherId}) : super();
  final String otherUsername;
  final String otherId;

  final chatTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    chatTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Provider.of<MessageProvider>(context, listen: false).enterDM(otherId);
    super.initState();
  }

  @override
  void deactivate() {
    Provider.of<MessageProvider>(context).exitDM(otherId);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    // for scrolling to bottom when new message arrives
    ScrollController _controller = ScrollController();
    bool firstBuild = true;

    Future<void> animateToBottom() async {
      print("animate to bottom");
      _controller.animateTo(
        _controller.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    }

    void send() {
      String message = chatTextController.text.trim();
      chatTextController.clear();
      if (message == "") return;
      sendMessage(otherId, message);
    }

    Future boxOpening = Provider.of<MessageProvider>(context, listen: false)
        .openBox(onlyASCII(otherId));

    User user = Provider.of<UserProvider>(context).user!;
    String userId = user.id!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.pinkAccent,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: AssetImage("assets/avatar.png"),
              maxRadius: 20,
              backgroundColor: Colors.white,
            ),
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
                  /* TODO online offline text
                  SizedBox(height: 6),
                  Text(
                    "Online",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                   */
                ],
              ),
            ),
          ],
        ),
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
                                '${onlyASCII(userId)}:$otherId')
                            .listenable(),
                        builder: (context, Box<ChatMessage> box, widget) {
                          List<ChatMessage> messages =
                              box.values.toList().cast();
                          if (!firstBuild) {
                            // new message incoming or sent
                            animateToBottom();
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
                                    child: SelectableText(
                                      messages[index].messageContent,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: messages[index].successful
                                            ? Colors.black
                                            : Colors.red,
                                      ),
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
                        onEditingComplete: () => send(),
                        controller: chatTextController,
                        decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                        onTap: () {
                          Timer(
                              Duration(milliseconds: 200),
                              () => _controller
                                  .jumpTo(_controller.position.maxScrollExtent));
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
                      onPressed: () => send(),
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
