import 'package:flutter/material.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/pages/dm.dart';
import 'package:jam/pages/profile/profile_other.dart';
import 'package:jam/widgets/profile_picture.dart';

Widget messagesList(List<ChatPair> chats, String emptyText) {
  if (chats.length == 0) {
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
              emptyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  return ListView.separated(
    itemBuilder: (context, index) {
      ChatPair currentChat = chats[index];
      return Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: ListTile(
          leading: IconButton(
            padding: EdgeInsets.all(0),
            iconSize: 70,
            icon: smallProfilePicture(currentChat.userId),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileOther(
                  otherUsername: currentChat.username,
                  otherId: currentChat.userId,
                ),
              ),
            ),
          ),
          title: Text(currentChat.username),
          subtitle: Text(currentChat.lastMessage),
          trailing: currentChat.unreadMessages == 0
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
                    currentChat.unreadMessages.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
          onTap: () {
            var name = currentChat.username;
            var id = currentChat.userId;
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
      );
    },
    separatorBuilder: (context, index) => Divider(
      color: Colors.grey,
    ),
    itemCount: chats.length,
  );
}
