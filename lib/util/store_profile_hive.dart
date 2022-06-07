import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/artist_model.dart';
import 'package:jam/models/track_model.dart';

Future storeTracksAndArtistsOther(
  String userId,
  String otherId,
  List<Track> commonTracks,
  List<Track> otherTracks,
  List<Artist> commonArtists,
  List<Artist> otherArtists,
  List<String> commonGenres,
  List<String> otherGenres,
) async {
  String boxName = tracksArtistsBoxName(userId, otherId);
  var box;
  if (!Hive.isBoxOpen(boxName)) {
    box = await Hive.openBox(boxName);
  } else {
    box = Hive.box(boxName);
  }
  box.put("commonTracks", commonTracks);
  box.put("commonArtists", commonArtists);
  box.put("commonGenres", commonGenres);
  box.put("otherTracks", otherTracks);
  box.put("otherArtists", otherArtists);
  box.put("otherGenres", otherGenres);
}

Future storeTracksAndArtistsSelf(
  String userId,
  List<Track> tracks,
  List<Artist> artists,
  List<String> genres,
) async {
  String boxName = tracksArtistsBoxName(userId, userId);
  var box;
  if (!Hive.isBoxOpen(boxName)) {
    box = await Hive.openBox(boxName);
  } else {
    box = Hive.box(boxName);
  }
  box.put("commonTracks", tracks);
  box.put("commonArtists", artists);
  box.put("commonGenres", genres);
}

Future storeLanguages(
  String userId,
  String otherUserId,
  List<String> languages,
) async {
  String boxName = languagesBoxName(userId);
  var box;
  if (!Hive.isBoxOpen(boxName)) {
    box = await Hive.openBox(boxName);
  } else {
    box = Hive.box(boxName);
  }
  box.put(otherUserId, languages);
}
