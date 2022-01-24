import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jam/providers/mqtt.dart' as mqttWrapper;
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/firebase.dart';
import 'package:jam/util/shared_preference.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '/config/routes.dart' as routes;

import '../models/user.dart';
import 'message_provider.dart';

class UserProvider with ChangeNotifier {
  User? _user = new User();

  User? get user => _user;

  void setUser(User? user, context) {
    print("set user içinde ${user?.username!}");
    mqttWrapper.connect(
      user!,
      Provider.of<MessageProvider>(context, listen: false),
      Provider.of<UnreadMessageProvider>(context, listen: false),
      context,
    );
    _user = user;
  }

  void logout() {
    _user = new User();
    UserPreferences().removeUser();
    mqttWrapper.disconnect();
    deleteToken();
    navigatorKey.currentState?.pushReplacementNamed(routes.login);
  }
}

void logout() {
  UserPreferences().removeUser();
  mqttWrapper.disconnect();
  deleteToken();
  navigatorKey.currentState?.pushReplacementNamed(routes.login);
}