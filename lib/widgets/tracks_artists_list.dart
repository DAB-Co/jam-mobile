import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';

tracksArtistsList(String userId, String otherUserId, context) {
  String commonTracksBoxName = commonTracks(userId, otherUserId);
  String commonArtistsBoxName = commonArtists(userId, otherUserId);
  String otherTracksBoxName = otherTracks(userId, otherUserId);
  String otherArtistsBoxName = otherArtists(userId, otherUserId);

  TextStyle headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  return Column(
    children: [
      Text(
        "Common Tracks:",
        style: headerStyle,
      ),
      SizedBox(height: 20),
      ValueListenableBuilder(
          valueListenable: Hive.box<String>(commonTracksBoxName).listenable(),
          builder: (context, Box<String> box, widget) {
            List<String> prefs = box.values.toList().cast();
            if (prefs.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note),
                    SizedBox(height: 10),
                    Text("No Common Tracks"),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) =>
                  ListTile(title: Text(prefs[index])),
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: prefs.length,
            );
          }),
      Divider(color: Colors.grey),
      Text(
        "Common Artists:",
        style: headerStyle,
      ),
      SizedBox(height: 20),
      ValueListenableBuilder(
          valueListenable: Hive.box<String>(commonArtistsBoxName).listenable(),
          builder: (context, Box<String> box, widget) {
            List<String> prefs = box.values.toList().cast();
            if (prefs.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_ind),
                    SizedBox(height: 10),
                    Text("No Common Artists"),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) =>
                  ListTile(title: Text(prefs[index])),
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: prefs.length,
            );
          }),
      Divider(color: Colors.grey),
      Text(
        "Other Tracks This User Listened To:",
        style: headerStyle,
      ),
      SizedBox(height: 20),
      ValueListenableBuilder(
          valueListenable: Hive.box<String>(otherTracksBoxName).listenable(),
          builder: (context, Box<String> box, widget) {
            List<String> prefs = box.values.toList().cast();
            if (prefs.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note),
                    SizedBox(height: 10),
                    Text("No Other Tracks"),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) =>
                  ListTile(title: Text(prefs[index])),
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: prefs.length,
            );
          }),
      Divider(color: Colors.grey),
      Text(
        "Other Artists This User Listened To:",
        style: headerStyle,
      ),
      SizedBox(height: 20),
      ValueListenableBuilder(
          valueListenable: Hive.box<String>(otherArtistsBoxName).listenable(),
          builder: (context, Box<String> box, widget) {
            List<String> prefs = box.values.toList().cast();
            if (prefs.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_ind),
                    SizedBox(height: 10),
                    Text("No Other Artists"),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) =>
                  ListTile(title: Text(prefs[index])),
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: prefs.length,
            );
          }),
      Divider(color: Colors.grey),
    ],
  );
}
