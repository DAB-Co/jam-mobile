import 'package:jam/util/util_functions.dart';

String messagesBoxName(String userId) {
  return onlyASCII("$userId:messages");
}

String chatBoxName(String thisUserId, String otherUserId) {
  return onlyASCII("$thisUserId:$otherUserId");
}