import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/models/otherUser.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/get_friends.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/local_notification.dart';
import 'package:jam/util/log_to_file.dart';
import 'package:jam/util/util_functions.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:provider/provider.dart';

/* Hive functions are usually here
  Hive boxes:
  - for every user ($thisUserId:messages)<ChatPair> (this is assigned to messages variable)
  - for every user and their friend ($thisUserId:$friendId)<ChatMessage>
 */

class SentMessage {
  String to;
  int index;

  SentMessage({required this.to, required this.index});
}

class MessageProvider extends ChangeNotifier {
  Map<int, SentMessage> unConfirmedMessages =
      Map<int, SentMessage>(); // messageId: to, index

  var messages;
  late User thisUser;
  String thisUserId = "";

  /// Do not increment unread if in DM page
  String inDmOf = "";

  Box<ChatMessage>? currentBox;

  Future init(UnreadMessageProvider unread, User _thisUser, context) async {
    thisUser = _thisUser;
    this.thisUserId = onlyASCII(thisUser.id!);
    // boxes can be opened once
    await Hive.initFlutter();

    ChatMessageAdapter chatMessageAdapter = new ChatMessageAdapter();
    ChatPairAdapter chatPairAdapter = new ChatPairAdapter();
    if (!Hive.isAdapterRegistered(chatMessageAdapter.typeId)) {
      Hive.registerAdapter(chatMessageAdapter);
    }
    if (!Hive.isAdapterRegistered(chatPairAdapter.typeId)) {
      Hive.registerAdapter(chatPairAdapter);
    }

    String messagesName = messagesBoxName(thisUserId);
    if (!Hive.isBoxOpen(messagesName)) {
      messages = await Hive.openBox<ChatPair>(messagesName);
    } else {
      messages = Hive.box<ChatPair>(messagesName);
    }
    unread.initUnreadCount(thisUserId);
    initFriends(thisUser, context);
  }

  /// adds message to the list
  void add(String otherId, ChatMessage message, UnreadMessageProvider unread,
      {int? msgId}) async {
    ChatPair? chatPair = messages.get(otherId);
    if (chatPair == null) {
      print("illegal message");
      return;
    }
    var chat;
    String chatName = chatBoxName(thisUserId, otherId);
    if (Hive.isBoxOpen(chatName)) {
      chat = Hive.box<ChatMessage>(chatName);
    } else {
      chat = await Hive.openBox<ChatMessage>(chatName);
    }
    if (msgId != null) {
      unConfirmedMessages[msgId] = SentMessage(to: otherId, index: chat.length);
    }
    String key = "${message.timestamp}";
    if (chat.get(key) != null) {
      print("double message: ${message.messageContent}");
      logToFile("double message: ${message.messageContent}\n");
      return;
    }
    await chat.put(key, message);
    print("adding message");
    chatPair.lastMessage = message.messageContent;
    chatPair.lastMessageTimeStamp = message.timestamp;
    // increase unread if not in current dm
    if (inDmOf != otherId) {
      chatPair.unreadMessages++;
      unread.incUnreadCount();
      showNotification(chatPair.username, int.parse(otherId));
    }
    messages.put(otherId, chatPair);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  Future openBox(String other) {
    return Hive.openBox<ChatMessage>(chatBoxName(thisUserId, other));
  }

  enterDM(username) {
    print("enter DM");
    print(username);
    inDmOf = username;
    ChatPair? chat = messages.get(username);
    if (chat == null) return;
    // read messages
    print(chat.unreadMessages.toString() + " okundu");
    chat.unreadMessages = 0;
    messages.put(username, chat);
    // clear this chat's notification
    flutterLocalNotificationsPlugin.cancel(int.parse(chat.userId));
  }

  exitDM(username) {
    print("exit DM");
    currentBox?.close();
    currentBox = null;
    inDmOf = "";
  }

  /// Take friends from server and save them to local storage
  Future initFriends(User user, context) async {
    List<OtherUser>? friendsList = await getFriends(user.id!, user.token!);
    if (friendsList == null) {
      // logout, wrong api token
      Provider.of<UserProvider>(context, listen: false).logout();
      showSnackBar(context, "Please Log In Again");
      return;
    }
    print("friendsList length: ${friendsList.length}");
    for (OtherUser friend in friendsList) {
      if (messages.get(friend.id) == null) {
        var chatPair = ChatPair(username: friend.username, userId: friend.id);
        messages.put(friend.id, chatPair);
      }
    }
  }

  /// Make message with given id red
  Future unsuccessfulMessage(int id) async {
    SentMessage? failure = unConfirmedMessages[id];
    if (failure == null) return;
    var chat;
    String chatName = chatBoxName(thisUserId, failure.to);
    if (Hive.isBoxOpen(chatName)) {
      chat = Hive.box<ChatMessage>(chatName);
    } else {
      chat = await Hive.openBox<ChatMessage>(chatName);
    }
    ChatMessage? failedMessage = chat.getAt(failure.index);
    if (failedMessage == null) return;
    failedMessage.successful = false;
    chat.putAt(failure.index, failedMessage);
  }

  void block(String otherId) {
    ChatPair? chatPair = messages.get(otherId);
    if (chatPair == null) {
      print("can not block");
      return;
    }
    chatPair.isBlocked = true;
    messages.put(otherId, chatPair);
    notifyListeners();
  }

  void unblock(String otherId) {
    ChatPair? chatPair = messages.get(otherId);
    if (chatPair == null) {
      print("can not unblock");
      return;
    }
    chatPair.isBlocked = false;
    messages.put(otherId, chatPair);
    notifyListeners();
  }
}
