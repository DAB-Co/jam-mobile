class ChatMessage{
  String messageContent;
  bool isIncomingMessage;
  String otherUser;
  ChatMessage({required this.messageContent, required this.isIncomingMessage, required this.otherUser});
}