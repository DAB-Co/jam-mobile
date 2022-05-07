import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/messages_list.dart';
import 'package:provider/provider.dart';

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
            List<ChatPair> blockedChats =
                chats.where((c) => c.isBlocked).toList();
            blockedChats.sort();
            return messagesList(blockedChats, "No blocked users");
          }),
    );
  }
}
