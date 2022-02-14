import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/util_functions.dart';
import 'package:provider/provider.dart';

import 'dm.dart';

class BlockedUsers extends StatefulWidget {
  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    String boxName = messagesBoxName(user.id!);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Blocked Users"),
        elevation: 0.1,
      ),
      body: ValueListenableBuilder(
          valueListenable: Hive.box<ChatPair>(boxName).listenable(),
          builder: (context, Box<ChatPair> box, widget) {
            List<ChatPair> chats = box.values.toList().cast();
            if (noBlockedUsers(chats)) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.messenger_outlined),
                    SizedBox(height: 10),
                    Text("No blocked users"),
                  ],
                ),
              );
            }
            chats.sort();
            return ListView.separated(
              shrinkWrap: true,
              // needed for this scrollable widget inside another scrollable widget
              itemBuilder: (context, index) => chats[index].isBlocked
                  ? Padding(
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
                          var id = chats[index].userId;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DM(
                                  otherUsername: name,
                                  otherId: id,
                                ),
                              ));
                        },
                      ),
                    )
                  : SizedBox(height: 0),
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: chats.length,
            );
          }),
    );
  }
}