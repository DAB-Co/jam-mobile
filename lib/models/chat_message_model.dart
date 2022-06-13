import 'package:hive/hive.dart';

part "chat_message_model.g.dart";

@HiveType(typeId: 1)
class ChatMessage {
  @HiveField(0)
  String messageContent;
  @HiveField(1)
  bool isIncomingMessage;
  @HiveField(2)
  int timestamp;
  @HiveField(3)
  bool successful;
  @HiveField(4)
  int? type;

  ChatMessage({
    required this.messageContent,
    required this.isIncomingMessage,
    required this.timestamp,
    required this.successful,
    required this.type,
  });
}
