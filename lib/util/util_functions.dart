import 'dart:io';
import 'dart:math';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:jam/models/chat_pair_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

void redirectToBrowser(String url) async {
  if (!await launch(url)) throw 'Could not launch $url';
}

/// Compress file and get file.
Future<File?> testCompressAndGetFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    quality: 25,
  );

  print(file.lengthSync());
  print(result?.lengthSync());

  return result;
}

Future<String> getProfilePicPath(String id) async {
  Directory dir = await getApplicationDocumentsDirectory();
  String path = dir.path;
  return "$path/pp_$id.jpg";
}
