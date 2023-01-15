import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/chat_message_model.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:jam/models/otherUser.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/wake.dart';
import 'package:jam/providers/mqtt.dart';
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/local_notification.dart';
import 'package:jam/util/profile_pic_utils.dart';
import 'package:jam/util/store_profile_hive.dart';
import 'package:jam/util/util_functions.dart';
import 'package:jam/widgets/inactive_dialog.dart';
import 'package:jam/widgets/show_snackbar.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../pages/select_color.dart';


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
    wake(thisUser, context);
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
      return;
    }
    await chat.put(key, message);
    print("adding message");
    if (message.type == MessageTypes.picture.index) {
      chatPair.lastMessage = "Image";
    } else {
      chatPair.lastMessage = message.messageContent;
    }
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
    // Important, check if exiting correct dm page
    if (inDmOf != username) return;
    print("exit DM");
    currentBox?.close();
    currentBox = null;
    inDmOf = "";
  }

  /// Make wake API call,
  /// Redirect to spotify login if refresh token is expired or not in server,
  /// Log out if api token is invalid
  /// Save friends to local storage
  /// Delete stored friend data that is not in wake
  Future wake(User user, context) async {
    Map<String, dynamic>? wakeResult = await wakeRequest(user.id!, user.token!);
    if (wakeResult == null) {
      // server error or network error
      print("wake result null");
      return;
    }
    if (wakeResult.containsKey("wrong_api_token")) {
      // wrong api token, logout
      Provider.of<UserProvider>(context, listen: false).logout();
      showSnackBar(context, "Please Log In Again");
      return;
    }
    print("user preferences: ${wakeResult["user_preferences"]}");
    if (wakeResult["user_preferences"].length == 0) {
      // redirect to color selection screen
      navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => SelectColor(
                wakeResult["user_preferences"]
            ),
          ),
          (Route<dynamic> route) => false);
      return;
    }
    else if (wakeResult["was_inactive"]) {
      // show inactive dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return inactiveDialog();
        },
      );
    }
    initFriends(wakeResult["friends"]);
    deleteNonFriends(user.id!, wakeResult["friends"]);
  }

  /// Take friends from server and save them to local storage
  Future initFriends(List<OtherUser> friendsList) async {
    print("friendsList length: ${friendsList.length}");
    for (OtherUser friend in friendsList) {
      if (messages.get(friend.id) == null) {
        var chatPair = ChatPair(
            username: friend.username,
            userId: friend.id,
            isBlocked: friend.isBlocked,
        );
        messages.put(friend.id, chatPair);
      }
    }
  }

  Future deleteNonFriends(String thisUserId, List<OtherUser> friendsList) async {
    List<String> friendIds = messages.keys.toList().cast<String>();
    Set<String> wakeFriendIds = Set<String>();
    for (OtherUser u in friendsList) {
      wakeFriendIds.add(u.id);
    }
    print(friendIds);
    print(wakeFriendIds);
    for (String currentId in friendIds) {
      if (!wakeFriendIds.contains(currentId)) {
        print("deleting user info: " + currentId);
        deleteProfilePicture(currentId);
        deleteSmallPicture(currentId);
        deleteTracksAndArtists(thisUserId, currentId);
        deleteLanguages(thisUserId, currentId);
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
