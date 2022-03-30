import 'package:hive/hive.dart';

part "tracks_artists_model.g.dart";

@HiveType(typeId: 2)
class TracksArtists {
  @HiveField(0)
  List<String> commonTracks;
  @HiveField(1)
  List<String> commonArtists;
  @HiveField(2)
  List<String> otherTracks;
  @HiveField(3)
  List<String> otherArtists;

  TracksArtists({
    required this.commonTracks,
    required this.commonArtists,
    required this.otherTracks,
    required this.otherArtists,
  });
}
