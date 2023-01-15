import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/models/artist_model.dart';
import 'package:jam/models/track_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/get_languages.dart';
import 'package:jam/network/top_preferences.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/store_profile_hive.dart';
import 'package:jam/widgets/profile_picture.dart';
import 'package:provider/provider.dart';

import '../../util/util_functions.dart';

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

    void _getAndSaveLanguages(userId, token, otherId) async {
      List<String>? langs = await getLanguagesCall(userId, token, otherId);
      if (langs != null) {
        storeLanguages(userId, otherId, langs);
      }
    }

    User user = Provider.of<UserProvider>(context).user!;
    String userId = user.id!;
    // request from server
    topPreferencesCall(userId, user.token!, otherId);
    _getAndSaveLanguages(userId, user.token!, otherId);
    // hive box names
    String colorBoxName = colorsBoxName(otherId);

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
            bigProfilePicture(otherId),
            SizedBox(height: 30),
            Divider(color: Colors.black),
            FutureBuilder(
              future: openHiveBox(colorBoxName),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    print("other profile future builder waiting");
                    return Center(child: CircularProgressIndicator());
                  default:
                    return ValueListenableBuilder(
                      valueListenable: Hive.box(colorBoxName).listenable(),
                      builder: (context, Box box, widget) {
                        try {
                          List<String> colors = box.get("colors");
                          return Column(
                            children: [
                              SizedBox(height: 20),
                              Text("$otherUsername's Colors:"),
                              SizedBox(height: 20),
                              colors.length == 0
                                  ? Text("No colors")
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) => ListTile(
                                        tileColor: fromHex(colors[index]),
                                      ),
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        color: Colors.grey,
                                      ),
                                      itemCount: colors.length,
                                    ),
                              SizedBox(height: 20),
                            ],
                          );
                        } catch (e) {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
