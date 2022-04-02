import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/artist_model.dart';
import 'package:jam/models/track_model.dart';

Future storeTracksAndArtists(
  String userId,
  String otherId,
  List<Track> commonTracks,
  List<Track> otherTracks,
  List<Artist> commonArtists,
  List<Artist> otherArtists,
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
  box.put("otherTracks", otherTracks);
  box.put("otherArtists", otherArtists);
}