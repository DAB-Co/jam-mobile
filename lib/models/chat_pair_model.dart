class ChatPair {
  String username;
  int unreadMessages = 0;
  String lastMessage = "";
  int lastMessageTimeStamp = -1;

  ChatPair({required this.username});
}
