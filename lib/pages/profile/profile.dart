import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/models/artist_model.dart';
import 'package:jam/models/track_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/top_preferences.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/alert.dart';
import 'package:jam/widgets/profile_picture.dart';
import 'package:jam/widgets/profile_lists.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  Future openHiveBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  @override
  Widget build(BuildContext context) {
    ArtistAdapter artistAdapter = new ArtistAdapter();
    TrackAdapter trackAdapter = new TrackAdapter();
    if (!Hive.isAdapterRegistered(artistAdapter.typeId)) {
      Hive.registerAdapter(artistAdapter);
    }
    if (!Hive.isAdapterRegistered(trackAdapter.typeId)) {
      Hive.registerAdapter(trackAdapter);
    }

    TextButton continueButton = TextButton(
      child: const Text("Log out"),
      onPressed: () {
        Provider.of<UserProvider>(context, listen: false).logout();
      },
    );
    AlertDialog alertDialog = alert("Attention!", continueButton,
        content: "Are you sure you want to log out?");

    User user = Provider.of<UserProvider>(context).user!;
    String userId = user.id!;

    topPreferencesCall(userId, user.token!, userId); // request from server
    String boxName = tracksArtistsBoxName(userId, userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text("Your Profile"),
        elevation: 0.1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            bigProfilePicture(user.id!),
            SizedBox(height: 30),
            Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                    ),
                    title: const Text('Change Profile Picture'),
                    onTap: () {
                      Navigator.pushNamed(context, profilePicSelection);
                    },
                  ),
                  Divider(color: Colors.grey),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: Colors.black,
                    ),
                    title: const Text('Your languages'),
                    onTap: () {
                      Navigator.pushNamed(context, chatLanguages);
                    },
                  ),
                  Divider(color: Colors.grey),
                  ListTile(
                    leading: Icon(
                      Icons.block,
                      color: Colors.red,
                    ),
                    title: const Text('Blocked users'),
                    onTap: () {
                      Navigator.pushNamed(context, blockedUsers);
                    },
                  ),
                  Divider(color: Colors.grey),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text('Logout'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alertDialog;
                        },
                      );
                    },
                  ),
                  Divider(color: Colors.black),
                  FutureBuilder(
                    future: openHiveBox(boxName),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          print("self profile future builder waiting");
                          return Center(child: CircularProgressIndicator());
                        default:
                          return tracksArtistsListSelf(userId, userId, context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
