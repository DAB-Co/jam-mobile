// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_artists_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TracksArtistsAdapter extends TypeAdapter<TracksArtists> {
  @override
  final int typeId = 2;

  @override
  TracksArtists read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TracksArtists(
      commonTracks: (fields[0] as List).cast<String>(),
      commonArtists: (fields[1] as List).cast<String>(),
      otherTracks: (fields[2] as List).cast<String>(),
      otherArtists: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TracksArtists obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.commonTracks)
      ..writeByte(1)
      ..write(obj.commonArtists)
      ..writeByte(2)
      ..write(obj.otherTracks)
      ..writeByte(3)
      ..write(obj.otherArtists);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TracksArtistsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
