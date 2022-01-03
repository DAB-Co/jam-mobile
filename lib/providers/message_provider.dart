import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/domain/otherUser.dart';
import 'package:jam/domain/user.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/network/get_friends.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/util_functions.dart';

class MessageProvider extends ChangeNotifier {
  var messages;

  late User thisUser;
  String thisUsername = "";

  /// Do not increment unread if in DM page
  String inDmOf = "";

  Box<ChatMessage>? currentBox;

  bool firstTime = true;

  Future init(UnreadMessageProvider unread, User _thisUser) async {
    if (firstTime) {
      await Hive.initFlutter();
      Hive.registerAdapter(ChatPairAdapter());
      Hive.registerAdapter(ChatMessageAdapter());
    }
    thisUser = _thisUser;
    thisUsername = onlyASCII(thisUser.username!);
    this.thisUsername = thisUsername;
    // boxes can be opened once
    messages = await Hive.openBox<ChatPair>('$thisUsername: messages');
    unread.initUnreadCount(thisUsername);
    initFriends(thisUser.id!);
    firstTime = false;
  }

  /// adds message to the list
  void add(
      String other, String otherId, ChatMessage message, UnreadMessageProvider unread) async {
    var chat = await Hive.openBox<ChatMessage>('$thisUsername:$other');
    await chat.add(message);
    print("incoming message adding");
    ChatPair? chatPair = messages.get(other);
    if (chatPair == null) {
      chatPair = ChatPair(username: other, userId: otherId);
      print("first message");
    }
    chatPair.lastMessage = message.messageContent;
    chatPair.lastMessageTimeStamp = message.timestamp;
    // increase unread if not in current dm
    if (inDmOf != other) {
      chatPair.unreadMessages++;
      unread.incUnreadCount();
    }
    messages.put(other, chatPair);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  Future openBox(String other) {
    return Hive.openBox<ChatMessage>('$thisUsername:$other');
  }

  messagesRead(String other) {
    print(other);
    ChatPair? chat = messages.get(other);
    if (chat == null) return;
    print(chat.unreadMessages.toString() + " okundu");
    chat.unreadMessages = 0;
    messages.put(other, chat);
  }

  enterDM(username) async {
    print("enter DM");
    inDmOf = username;
  }

  exitDM(username) {
    print("exit DM");
    currentBox?.close();
    currentBox = null;
    inDmOf = "";
  }

  /// Take friends from server and save them to local storage
  Future initFriends(String userId) async {
    var friendsList = await getFriends(userId);
    print("friendsList length: ${friendsList.length}");
    for (OtherUser friend in friendsList) {
      if (messages.get(friend.username) == null) {
        var chatPair = ChatPair(username: friend.username, userId: friend.id);
        messages.put(friend.username, chatPair);
      }
    }
  }
}
