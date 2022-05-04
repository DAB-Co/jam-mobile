import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/pages/dm.dart';
import 'package:jam/pages/profile/profile_other.dart';
import 'package:jam/util/util_functions.dart';
import 'package:jam/widgets/profile_picture.dart';

messagesList(user, context) {
  String boxName = messagesBoxName(user.id);

  return ValueListenableBuilder(
      valueListenable: Hive.box<ChatPair>(boxName).listenable(),
      builder: (context, Box<ChatPair> box, widget) {
        List<ChatPair> chats = box.values.toList().cast();
        if (noAvailableUsers(chats)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.messenger_outlined),
                  SizedBox(height: 10),
                  Text(
                    "There will be other people here who share the same music taste soon",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        chats.sort();
        return ListView.separated(
          itemBuilder: (context, index) => !chats[index].isBlocked
              ? Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: ListTile(
                    leading: IconButton(
                      padding: EdgeInsets.all(0),
                      iconSize: 70,
                      icon: smallProfilePicture(chats[index].userId),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileOther(
                            otherUsername: chats[index].username,
                            otherId: chats[index].userId,
                          ),
                        ),
                      ),
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
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(height: 0),
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
          ),
          itemCount: chats.length,
        );
      });
}
