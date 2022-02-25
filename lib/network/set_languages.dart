import 'package:jam/config/app_url.dart';
import 'package:jam/network/network_call.dart';

/// Returns true if language is set successfully in server
Future<bool> setLanguages(List<String> iso, bool toAdd) async {
  Map<String, String?> dataToSend = {};
  if (toAdd) {
    dataToSend["add"] = iso.toString();
  } else {
    dataToSend["remove"] = iso.toString();
  }
  return networkCall(dataToSend, AppUrl.setLanguages);
}
