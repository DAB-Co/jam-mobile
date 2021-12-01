import 'package:flutter/foundation.dart';
import 'package:jam/providers/mqtt.dart' as mqttWrapper;
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/shared_preference.dart';
import 'package:provider/provider.dart';

import '/domain/user.dart';
import 'message_provider.dart';

class UserProvider with ChangeNotifier {
  User? _user = new User();

  User? get user => _user;

  void setUser(User? user, context) {
    print("set user içinde ${user?.username!}");
    mqttWrapper.connect(
        user!.username!,
        user.token!,
        Provider.of<MessageProvider>(context, listen: false),
        Provider.of<UnreadMessageProvider>(context, listen: false));
    _user = user;
    // notifyListeners();
  }

  void logout() {
    _user = new User();
    UserPreferences().removeUser();
    mqttWrapper.disconnect();
  }
}
