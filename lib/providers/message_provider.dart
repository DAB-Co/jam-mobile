import 'package:flutter/material.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/chat_pair_model.dart';

class MessageProvider extends ChangeNotifier {
  /// Internal, private state of messages
  Map<String, ChatPair> _chats = Map();

  /// Number of unread messages
  int nofUnread = 0;

  /// adds message to the list
  void add(ChatMessage message) {
    var other = message.otherUser;
    _chats.putIfAbsent(other, () => ChatPair(username: other));
    _chats[other]!.messageHistory.add(message);
    nofUnread++;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  getAllChats() {
    return _chats.values.toList();
  }

  getChat(String username) {
    return _chats[username]!.messageHistory;
  }
}
