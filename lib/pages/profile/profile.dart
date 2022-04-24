import 'package:flutter/material.dart';
import 'package:jam/config/routes.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/widgets/alert.dart';
import 'package:jam/widgets/profile_picture.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    TextButton continueButton = TextButton(
      child: const Text("Log out"),
      onPressed: () {
        Provider.of<UserProvider>(context, listen: false).logout();
      },
    );
    AlertDialog alertDialog = alert("Attention!", continueButton,
        content: "Are you sure you want to log out?");

    User user = Provider.of<UserProvider>(context).user!;

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
                ],
              ),
            ),
            Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
