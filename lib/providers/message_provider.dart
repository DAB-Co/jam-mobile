import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/chat_pair_model.dart';

class MessageProvider extends ChangeNotifier {

  var messages;

  /// Number of unread messages
  int nofUnread = 0;

  /// Do not increment unread if in DM page
  String inDmOf = "";

  Box<ChatMessage>? currentBox;

  Future init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatPairAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    messages = await Hive.openBox<ChatPair>('messages');
  }

  /// adds message to the list
  void add(String other, ChatMessage message) async {
    var chat = await Hive.openBox<ChatMessage>(other);
    await chat.add(message);
    ChatPair? chatPair = messages.get(other);
    if (chatPair != null) {
      print("not first message");
      chatPair.lastMessage = message.messageContent;
      chatPair.lastMessageTimeStamp = message.timestamp;
      if (inDmOf != other) {
        chatPair.unreadMessages++;
      }
      messages.put(other, chatPair);
    } else {
      print("first message");
      chatPair = ChatPair(username: other);
      chatPair.lastMessage = message.messageContent;
      chatPair.lastMessageTimeStamp = message.timestamp;
    }
    messages.put(other, chatPair);
    if (inDmOf != other) {
      nofUnread++;
    }
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  messagesRead(String other) {
    print(other);
    ChatPair? chat = messages.get(other);
    if (chat == null) return;
    nofUnread -= chat.unreadMessages;
    print(chat.unreadMessages.toString() + "okundu");
    chat.unreadMessages = 0;
    notifyListeners();
  }

  enterDM(username) async {
    print("enter DM");
    //currentBox = await Hive.openBox<ChatMessage>(username);
    inDmOf = username;
  }

  exitDM(username) {
    print("exit DM");
    currentBox?.close();
    currentBox = null;
    inDmOf = "";
  }
}
