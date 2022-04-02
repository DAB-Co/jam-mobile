import 'package:hive/hive.dart';

part "artist_model.g.dart";

@HiveType(typeId: 3)
class Artist {
  @HiveField(0)
  String name;
  @HiveField(1)
  String imageUrl;
  @HiveField(2)
  String spotifyUrl;
  @HiveField(3)
  String? genre;

  Artist(
      {required this.name,
      required this.imageUrl,
      required this.spotifyUrl,
      this.genre});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Artist &&
              runtimeType == other.runtimeType &&
              name == other.name;

  @override
  int get hashCode => name.hashCode;
}
