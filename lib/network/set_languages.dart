import 'package:jam/config/app_url.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/network_call.dart';

/// Returns true if language is set successfully in server
Future<bool> setLanguages(User user, List<String> iso, bool toAdd) async {
  Map<String, dynamic> dataToSend = {
    "user_id": user.id!,
    "api_token": user.token!,
  };
  if (toAdd) {
    dataToSend["add_languages"] = iso;
    dataToSend["remove_languages"] = [];
  } else {
    dataToSend["add_languages"] = [];
    dataToSend["remove_languages"] = iso;
  }
  return networkCall(dataToSend, AppUrl.setLanguages);
}
