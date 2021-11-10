import 'package:jam/models/chat_message_model.dart';

class ChatPair{
  String username;
  List<ChatMessage> messageHistory = [];
  int unreadMessages = 0;
  ChatPair({required this.username});
}