class ChatMessage {
  String messageContent;
  bool isIncomingMessage;
  int timestamp;

  ChatMessage(
      {required this.messageContent,
      required this.isIncomingMessage,
      required this.timestamp});
}
