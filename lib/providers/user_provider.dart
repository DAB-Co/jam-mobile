import 'package:flutter/material.dart';
import 'package:jam/providers/mqtt.dart' as mqttWrapper;
import 'package:jam/providers/unread_message_counter.dart';
import 'package:jam/util/firebase.dart';
import 'package:jam/util/shared_preference.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;
import '../main.dart';
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

  void addLanguage(String lan) {
    List<String>? langs = user!.chatLanguages;
    if (langs == null) {
      user!.chatLanguages = [lan];
      UserPreferences().saveUser(user!);
    } else if (!langs.contains(lan)) {
      langs.add(lan);
      UserPreferences().saveUser(user!);
    }
  }

  void removeLanguage(String lan) {
    List<String>? langs = user!.chatLanguages;
    if (langs == null) {
      return;
    } else if (langs.contains(lan)) {
      langs.remove(lan);
      UserPreferences().saveUser(user!);
    }
  }

  void logout() {
    _user = new User();
    UserPreferences().removeUser();
    mqttWrapper.disconnect();
    deleteToken();
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
        routes.login, (Route<dynamic> route) => false);
  }
}

void logout() {
  UserPreferences().removeUser();
  mqttWrapper.disconnect();
  deleteToken();
  navigatorKey.currentState
      ?.pushNamedAndRemoveUntil(routes.login, (Route<dynamic> route) => false);
}
