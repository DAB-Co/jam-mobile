// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_pair_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatPairAdapter extends TypeAdapter<ChatPair> {
  @override
  final int typeId = 0;

  @override
  ChatPair read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatPair(
      username: fields[0] as String,
      userId: fields[4] as String,
    )
      ..unreadMessages = fields[1] as int
      ..lastMessage = fields[2] as String
      ..lastMessageTimeStamp = fields[3] as int
      ..isBlocked = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, ChatPair obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.unreadMessages)
      ..writeByte(2)
      ..write(obj.lastMessage)
      ..writeByte(3)
      ..write(obj.lastMessageTimeStamp)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.isBlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatPairAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
