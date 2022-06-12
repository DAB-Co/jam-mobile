import 'package:jam/config/app_url.dart';

import 'network_call.dart';

/// Sends message to server, returns true if server returns success message
Future<bool> sendForgotPasswordRequest(String email) async {
  final Map<String, String> dataToSend = {
    "user_id": email,
  };
  return networkCall(dataToSend, AppUrl.forgotPassword);
}
