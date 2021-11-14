import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/providers/message_provider.dart';
import 'package:provider/provider.dart';

import 'dm.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Messages"),
        elevation: 0.1,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15, top: 5, bottom: 5),
            child: Image(
              image: AssetImage("assets/avatar.png"),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: Hive.box<ChatPair>("messages").listenable(),
          builder: (context, Box<ChatPair> box, widget) {
            List<ChatPair> chats = box.values.toList().cast();
            return ListView.separated(
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: ListTile(
                  leading: Image(
                    image: AssetImage("assets/avatar.png"),
                  ),
                  title: Text(chats[index].username),
                  subtitle: Text(chats[index].lastMessage),
                  trailing: chats[index].unreadMessages == 0
                      ? Text("")
                      : Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          child: Text(
                            chats[index].unreadMessages.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                  onTap: () {
                    var name = chats[index].username;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DM(
                            otherUsername: name,
                            unRead: Provider.of<MessageProvider>(context,
                                    listen: false)
                                .messages
                                .get(name)
                                .unreadMessages),
                      ),
                    );
                  },
                ),
              ),
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: chats.length,
            );
          }),
    );
  }
}
