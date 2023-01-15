import 'dart:math';
import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';

/// Removes non ASCII characters
String onlyASCII(String str) {
  return str.replaceAll(RegExp(r'[^A-Za-z0-9().,;?]'), '');
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

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
