import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/models/otherUser.dart';
import 'package:jam/models/user.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/network/get_friends.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/providers/user_provider.dart';
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
  Map<int, SentMessage> unConfirmedMessages = Map<int, SentMessage>(); // messageId: to, index

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

    if (!Hive.isBoxOpen('$thisUserId:messages')) {
      messages = await Hive.openBox<ChatPair>('$thisUserId:messages');
    }
    else {
      messages = Hive.box<ChatPair>('$thisUserId:messages');
    }
    unread.initUnreadCount(thisUserId);
    initFriends(thisUser, context);
  }

  /// adds message to the list
  void add(String otherId, ChatMessage message, UnreadMessageProvider unread, {int? msgId}) async {
    ChatPair? chatPair = messages.get(otherId);
    if (chatPair == null) {
      print("illegal message");
      return;
    }
    var chat = await Hive.openBox<ChatMessage>('$thisUserId:$otherId');
    if (msgId != null) {
      unConfirmedMessages[msgId] = SentMessage(to: otherId, index: chat.length);
    }
    await chat.add(message);
    print("adding message");
    chatPair.lastMessage = message.messageContent;
    chatPair.lastMessageTimeStamp = message.timestamp;
    // increase unread if not in current dm
    if (inDmOf != otherId) {
      chatPair.unreadMessages++;
      unread.incUnreadCount();
    }
    messages.put(otherId, chatPair);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  Future openBox(String other) {
    return Hive.openBox<ChatMessage>('$thisUserId:$other');
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
    var chat = await Hive.openBox<ChatMessage>('$thisUserId:${failure.to}');
    ChatMessage? failedMessage = chat.getAt(failure.index);
    if (failedMessage == null) return;
    failedMessage.successful = false;
    chat.putAt(failure.index, failedMessage);
  }
}
