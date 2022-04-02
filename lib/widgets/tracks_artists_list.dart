import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/artist_model.dart';
import 'package:jam/models/track_model.dart';
import 'package:jam/util/util_functions.dart';

_noTrackOrArtist(String text, Icon icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        SizedBox(height: 10),
        Text(text),
        SizedBox(height: 20),
      ],
    ),
  );
}

_trackList(List<Track> list) {
  return ListView.separated(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) => ListTile(
      leading: CachedNetworkImage(
        placeholder: (context, url) => const CircularProgressIndicator(),
        width: 64,
        height: 64,
        imageUrl: list[index].imageUrl,
      ),
      title: GestureDetector(
        onTap: () => redirectToBrowser(list[index].spotifyUrl),
        child: Text(
          list[index].name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            "Album: ${list[index].albumName}\nArtist: ${list[index].artist}"),
      ),
    ),
    separatorBuilder: (context, index) => Divider(
      color: Colors.grey,
    ),
    itemCount: list.length,
  );
}

_artistList(List<Artist> list) {
  return ListView.separated(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) => ListTile(
      leading: CachedNetworkImage(
        placeholder: (context, url) => const CircularProgressIndicator(),
        width: 64,
        height: 64,
        imageUrl: list[index].imageUrl,
      ),
      title: GestureDetector(
        onTap: () => redirectToBrowser(list[index].spotifyUrl),
        child: Text(
          list[index].name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Genres: ${list[index].genre}"),
      ),
    ),
    separatorBuilder: (context, index) => Divider(
      color: Colors.grey,
    ),
    itemCount: list.length,
  );
}

tracksArtistsList(String userId, String otherUserId, context) {
  String commonTracksBoxName = tracksArtistsBoxName(userId, otherUserId);

  TextStyle headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  return ValueListenableBuilder(
    valueListenable: Hive.box(commonTracksBoxName).listenable(),
    builder: (context, Box box, widget) {
      List<Track>? commonTracks = box.get("commonTracks");
      List<Artist>? commonArtists = box.get("commonArtists");
      List<Track>? otherTracks = box.get("otherTracks");
      List<Artist>? otherArtists = box.get("otherArtists");

      return Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Common Tracks:",
            style: headerStyle,
          ),
          SizedBox(height: 20),
          commonTracks == null || commonTracks.length == 0
              ? _noTrackOrArtist("No Common Tracks", Icon(Icons.music_note))
              : _trackList(commonTracks),
          Divider(color: Colors.black),
          SizedBox(height: 20),
          Text(
            "Common Artists:",
            style: headerStyle,
          ),
          SizedBox(height: 20),
          commonArtists == null || commonArtists.length == 0
              ? _noTrackOrArtist(
                  "No Common Artists", Icon(Icons.assignment_ind))
              : _artistList(commonArtists),
          Divider(color: Colors.black),
          SizedBox(height: 20),
          Text(
            "Other Tracks This User Listened To:",
            style: headerStyle,
          ),
          SizedBox(height: 20),
          otherTracks == null || otherTracks.length == 0
              ? _noTrackOrArtist("No Other Tracks", Icon(Icons.music_note))
              : _trackList(otherTracks),
          Divider(color: Colors.black),
          SizedBox(height: 20),
          Text(
            "Other Artists This User Listened To:",
            style: headerStyle,
          ),
          SizedBox(height: 20),
          otherArtists == null || otherArtists.length == 0
              ? _noTrackOrArtist("No Other Artists", Icon(Icons.assignment_ind))
              : _artistList(otherArtists),
          SizedBox(height: 20),
        ],
      );
    },
  );
}
