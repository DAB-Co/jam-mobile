import 'package:flutter/material.dart';
import 'package:jam/util/shared_preference.dart';

class UnreadMessageProvider extends ChangeNotifier {
  /// Number of unread messages
  int nofUnread = 0;

  String username = "";

  void initUnreadCount(String username) async {
    print("init unread");
    this.username = username;
    var oldUnread = await UserPreferences().getUnreadMessageCount(username);
    print("old unread: $oldUnread");
    if (oldUnread != null) {
      nofUnread = oldUnread;
    } else {
      nofUnread = 0; // important for logout
    }
    notifyListeners();
  }

  void incUnreadCount() async {
    print("bir okunmadık var");
    nofUnread++;
    UserPreferences().incrementUnreadMessageCount(username);
    notifyListeners();
  }

  void decUnreadCount(int read) async {
    print("dec unread count içinde");
    nofUnread -= read;
    if (nofUnread < 0) {
      nofUnread = 0;
    }
    UserPreferences().decrementUnreadMessageCount(username, read);
    notifyListeners();
  }
}