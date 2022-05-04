import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/config/box_names.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/models/artist_model.dart';
import 'package:jam/models/track_model.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/delete_account.dart';
import 'package:jam/network/top_preferences.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/validators.dart';
import 'package:jam/widgets/alert.dart';
import 'package:jam/widgets/form_widgets.dart';
import 'package:jam/widgets/loading.dart';
import 'package:jam/widgets/profile_lists.dart';
import 'package:jam/widgets/profile_picture.dart';
import 'package:jam/widgets/show_snackbar.dart';
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

    User user = Provider.of<UserProvider>(context).user!;
    String userId = user.id!;

    AlertDialog logoutDialog = alert(
      "Attention!",
      TextButton(
        child: const Text("Log out"),
        onPressed: () {
          Provider.of<UserProvider>(context, listen: false).logout();
        },
      ),
      content: Text("Are you sure you want to log out?"),
    );

    bool deleting = false;
    String? _password;
    final formKey = new GlobalKey<FormState>();
    AlertDialog deleteAccountDialog = alert(
      "Attention!",
      TextButton(
        child: const Text("Delete Account"),
        onPressed: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  actions: deleting ? [] : [cancelButton],
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15.0),
                          Text("Password"),
                          SizedBox(height: 5.0),
                          TextFormField(
                            autofocus: false,
                            obscureText: true,
                            validator: (value) => validatePassword(value),
                            onSaved: (value) => _password = value,
                            decoration: buildInputDecoration(
                                "Enter your password", Icons.lock),
                          ),
                          SizedBox(height: 20.0),
                          deleting
                              ? loading("Please wait")
                              : longButtons(
                                  "Delete Account",
                                  () async {
                                    setState(() {
                                      deleting = true;
                                    });
                                    final form = formKey.currentState!;
                                    if (form.validate()) {
                                      form.save();
                                      String? result = await deleteAccountCall(userId, _password!);
                                      if (result == null) {
                                        Navigator.pop(context);
                                        showSnackBar(context, "Check your connection");
                                      } else if (result == "OK") {
                                        Provider.of<UserProvider>(context, listen: false).logout();
                                      } else {
                                        Navigator.pop(context);
                                        showSnackBar(context, result);
                                      }
                                    }
                                    setState(() {
                                      deleting = false;
                                    });
                                  },
                                  color: Colors.red,
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          );
        },
      ),
      content: Text(
          "Are you sure you want to delete your account? This action is irreversible and you will lose all of your matches forever!"),
    );

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
                          return logoutDialog;
                        },
                      );
                    },
                  ),
                  Divider(color: Colors.grey),
                  ListTile(
                    leading: Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                    ),
                    title: const Text('Delete Account'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return deleteAccountDialog;
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
