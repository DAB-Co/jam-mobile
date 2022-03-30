import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/top_preferences.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/tracks_artists_list.dart';
import 'package:provider/provider.dart';

class ProfileOther extends StatefulWidget {
  const ProfileOther({required this.otherUsername, required this.otherId})
      : super();
  final String otherUsername;
  final String otherId;

  @override
  _ProfileOtherState createState() =>
      _ProfileOtherState(otherUsername: otherUsername, otherId: otherId);
}

class _ProfileOtherState extends State<ProfileOther> {
  _ProfileOtherState({required this.otherUsername, required this.otherId})
      : super();
  final String otherUsername;
  final String otherId;

  Future openHiveBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<List<String>>(boxName);
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;
    String userId = user.id!;
    topPreferencesCall(userId, user.token!, otherId); // request from server
    String boxName = tracksArtistsBoxName(userId, otherId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(otherUsername),
        elevation: 0.1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/avatar.png'),
                ),
              ),
            ),
            SizedBox(height: 30),
            Divider(color: Colors.black),
            FutureBuilder(
              future: openHiveBox(boxName),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    print("other profile future builder waiting");
                    return Center(child: CircularProgressIndicator());
                  default:
                    return tracksArtistsList(user.id!, otherId, context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
