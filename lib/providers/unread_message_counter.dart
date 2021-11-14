import 'package:flutter/material.dart';
import 'package:jam/util/shared_preference.dart';

class UnreadMessageProvider extends ChangeNotifier {
  /// Number of unread messages
  int nofUnread = 0;

  void initUnreadCount() async {
    var oldUnread = await UserPreferences().getUnreadMessageCount();
    if (oldUnread != null) {
      nofUnread = oldUnread;
    }
    notifyListeners();
  }

  void incUnreadCount() async {
    print("bir okunmadık var");
    nofUnread++;
    UserPreferences().incrementUnreadMessageCount();
    notifyListeners();
  }

  void decUnreadCount(int read) async {
    print("okunuyor provider içinde");
    nofUnread -= read;
    UserPreferences().decrementUnreadMessageCount(read);
    notifyListeners();
  }
}