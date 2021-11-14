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

  Future init() async {
    await Hive.initFlutter();
    messages = await Hive.openBox<ChatPair>('messages');
  }

  /// adds message to the list
  void add(String other, ChatMessage message) async {
    var chat = await Hive.openBox<ChatMessage>(other);
    chat.add(message);
    chat.close();
    ChatPair? chatPair = messages.get(other);
    if (chatPair != null) {
      chatPair.lastMessage = message.messageContent;
      chatPair.lastMessageTimeStamp = message.timestamp;
      if (inDmOf != other) {
        chatPair.unreadMessages++;
      }
    }
    if (inDmOf != other) {
      nofUnread++;
    }
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  messagesRead(String other) {
    print(other);
    ChatPair? chat = messages.get<ChatMessage>(other);
    if (chat == null) return;
    nofUnread -= chat.unreadMessages;
    print(chat.unreadMessages.toString() + "okundu");
    chat.unreadMessages = 0;
    notifyListeners();
  }

  enterDM(username) {
    print("enter DM");
    inDmOf = username;
  }

  exitDM() {
    print("exit DM");
    inDmOf = "";
  }
}
