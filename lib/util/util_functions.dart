import 'dart:math';

import 'package:jam/models/chat_pair_model.dart';

/// Removes non ASCII characters
String onlyASCII(String str) {
  return str.replaceAll(RegExp(r'[^A-Za-z0-9().,;?]'), '');
}

/// Returns true if chats has no blocked users
bool noBlockedUsers(List<ChatPair> chats) {
  for (ChatPair c in chats) {
    if (c.isBlocked) return false;
  }
  return true;
}

/// Returns true if chats has no unblocked users
bool noAvailableUsers(List<ChatPair> chats) {
  for (ChatPair c in chats) {
    if (!c.isBlocked) return false;
  }
  return true;
}

/// Returns query URL such as /spotify/login?user_id=1&api_token=1
String urlQuery(String baseUrl, Map<String, String> query) {
  String result = "$baseUrl?";
  query.forEach((k, v) {
    result += "$k=$v&";
  });
  result = result.substring(0, result.length - 1);
  return result;
}

String getRandomString(int length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  return String.fromCharCodes(Iterable.generate(
    length,
    (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
  ));
}
