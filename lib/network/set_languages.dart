import 'package:jam/config/app_url.dart';
import 'package:jam/network/network_call.dart';

/// Returns true if language is set successfully in server
Future<bool> setLanguages(List<String> iso, bool toAdd) async {
  Map<String, String?> dataToSend = {};
  if (toAdd) {
    dataToSend["add_languages"] = iso.toString();
    dataToSend["remove_languages"] = "[]";
  } else {
    dataToSend["add_languages"] = "[]";
    dataToSend["remove_languages"] = iso.toString();
  }
  return networkCall(dataToSend, AppUrl.setLanguages);
}
