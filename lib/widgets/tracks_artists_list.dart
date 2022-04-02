import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/artist_model.dart';
import 'package:jam/models/track_model.dart';

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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note),
                      SizedBox(height: 10),
                      Text("No Common Tracks"),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(commonTracks[index].name)),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
                  itemCount: commonTracks.length,
                ),
          Divider(color: Colors.black),
          SizedBox(height: 20),
          Text(
            "Common Artists:",
            style: headerStyle,
          ),
          SizedBox(height: 20),
          commonArtists == null || commonArtists.length == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_ind),
                      SizedBox(height: 10),
                      Text("No Common Artists"),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(commonArtists[index].name)),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
                  itemCount: commonArtists.length,
                ),
          Divider(color: Colors.black),
          SizedBox(height: 20),
          Text(
            "Other Tracks This User Listened To:",
            style: headerStyle,
          ),
          SizedBox(height: 20),
          otherTracks == null || otherTracks.length == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note),
                      SizedBox(height: 10),
                      Text("No Other Tracks"),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(otherTracks[index].name)),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
                  itemCount: otherTracks.length,
                ),
          Divider(color: Colors.black),
          SizedBox(height: 20),
          Text(
            "Other Artists This User Listened To:",
            style: headerStyle,
          ),
          SizedBox(height: 20),
          otherArtists == null || otherArtists.length == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_ind),
                      SizedBox(height: 10),
                      Text("No Other Artists"),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(otherArtists[index].name)),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
                  itemCount: otherArtists.length,
                ),
          SizedBox(height: 20),
        ],
      );
    },
  );
}
