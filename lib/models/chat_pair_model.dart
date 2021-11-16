import 'package:hive/hive.dart';

part "chat_pair_model.g.dart";

@HiveType(typeId: 0)
class ChatPair implements Comparable {
  @HiveField(0)
  String username;
  @HiveField(1)
  int unreadMessages = 0;
  @HiveField(2)
  String lastMessage = "";
  @HiveField(3)
  int lastMessageTimeStamp = -1;

  ChatPair({required this.username});

  @override
  int compareTo(other) {
    return other.lastMessageTimeStamp.compareTo(this.lastMessageTimeStamp);
  }
}
