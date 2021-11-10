import 'package:flutter/material.dart';
import 'package:jam/models/chat_message_model.dart';

class MessageProvider extends ChangeNotifier {
  /// Internal, private state of messages
  List<ChatMessage> _items = [];

  /// Number of unread messages
  int nofUnread = 0;

  /// adds message to the list
  void add(ChatMessage message) {
    _items.add(message);
    nofUnread++;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}