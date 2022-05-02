import 'package:jam/config/app_url.dart';
import 'package:jam/network/network_call.dart';

/// Sends message to server, returns true if server returns success message
Future<bool> deleteAccountCall(String userId, String password) async {
  final Map<String, dynamic> dataToSend = {
    "user_id": userId,
    "password": password,
  };
  return networkCall(dataToSend, AppUrl.deleteAccount);
}
