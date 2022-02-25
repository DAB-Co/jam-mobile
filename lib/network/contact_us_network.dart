import 'package:jam/config/app_url.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/network_call.dart';

/// Sends message to server, returns true if server returns success message
Future<bool> sendContactUsRequest(User user, String? message) async {
  final Map<String, String?> dataToSend = {
    "user_id": user.id!,
    "api_token": user.token!,
    "suggestion": message,
  };
  return networkCall(dataToSend, AppUrl.suggestion);
}
