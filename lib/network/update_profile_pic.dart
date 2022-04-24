import 'package:jam/config/app_url.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/network_call.dart';

/// Sends message to server, returns true if server returns success message
Future<bool> updateProfilePicCall(User user, originalPicture, smallPicture) async {
  final Map<String, dynamic> dataToSend = {
    "user_id": user.id!,
    "api_token": user.token!,
    "original_picture": originalPicture,
    "small_picture": smallPicture,
  };
  return networkCall(dataToSend, AppUrl.updateProfilePic);
}
