import 'package:jam/util/util_functions.dart';

String messagesBoxName(String userId) {
  return onlyASCII("$userId:messages");
}

String chatBoxName(String thisUserId, String otherUserId) {
  return onlyASCII("$thisUserId:$otherUserId");
}

String commonTracks(String userId, String otherUserId) {
  return onlyASCII("common_tracks:$userId,$otherUserId");
}

String commonArtists(String userId, String otherUserId) {
  return onlyASCII("common_artists:$userId,$otherUserId");
}

String otherTracks(String userId, String otherUserId) {
  return onlyASCII("other_tracks:$userId,$otherUserId");
}

String otherArtists(String userId, String otherUserId) {
  return onlyASCII("other_artists:$userId,$otherUserId");
}
