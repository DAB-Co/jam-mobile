import 'package:flutter/material.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/chat_pair_model.dart';

class MessageProvider extends ChangeNotifier {
  /// Internal, private state of messages
  Map<String, ChatPair> _chats = Map();

  /// Number of unread messages
  int nofUnread = 0;

  /// Do not increment unread if in DM page
  String inDmOf = "";

  /// adds message to the list
  void add(ChatMessage message) {
    var other = message.otherUser;
    _chats.putIfAbsent(other, () => ChatPair(username: other));
    _chats[other]!.messageHistory.add(message);
    if (inDmOf != other) {
      _chats[other]!.unreadMessages++;
      nofUnread++;
    }
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  getAllChats() {
    return _chats.values.toList();
  }

  getChat(String username) {
    return _chats[username]!.messageHistory;
  }

  messagesRead(String other) {
    print(other);
    if (!_chats.containsKey(other)) return;
    nofUnread -= _chats[other]!.unreadMessages;
    print(_chats[other]!.unreadMessages.toString() + "okundu");
    _chats[other]?.unreadMessages = 0;
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
