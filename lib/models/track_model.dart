import 'package:hive/hive.dart';

part "track_model.g.dart";

@HiveType(typeId: 2)
class Track {
  @HiveField(0)
  String name;
  @HiveField(1)
  String imageUrl;
  @HiveField(2)
  String spotifyUrl;
  @HiveField(3)
  String? previewUrl;
  @HiveField(4)
  String? albumName;
  @HiveField(5)
  String? artist;

  Track(
      {required this.name,
      required this.imageUrl,
      required this.spotifyUrl,
      this.previewUrl,
      this.albumName,
      this.artist});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Track &&
              runtimeType == other.runtimeType &&
              name == other.name;

  @override
  int get hashCode => name.hashCode;

}
