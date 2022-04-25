import 'package:jam/util/util_functions.dart';

String messagesBoxName(String userId) {
  return onlyASCII("$userId:messages");
}

String chatBoxName(String thisUserId, String otherUserId) {
  return onlyASCII("$thisUserId:$otherUserId");
}

String tracksArtistsBoxName(String userId, String otherUserId) {
  return onlyASCII("tracksAndArtists:$userId,$otherUserId");
}

String languagesBoxName(String userId) {
  return onlyASCII("languages:$userId");
}
