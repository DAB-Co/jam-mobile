import 'package:flutter/material.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AvatarCustomize extends StatefulWidget {
  @override
  _AvatarCustomizeState createState() => _AvatarCustomizeState();
}

class _AvatarCustomizeState extends State<AvatarCustomize> {
  @override
  Widget build(BuildContext context) {
    // set up the buttons in alert
    Widget cancelButton = TextButton(
      child: Text("Go back"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Log out"),
      onPressed: () {
        Provider.of<UserProvider>(context, listen: false).logout();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Attention!"),
      content: Text("Are you sure you want to log out?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Center(
          child: Text(""),
        ),
        elevation: 0.1,
      ),
      body: Column(
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
          Divider(
            color: Colors.grey
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
            ),
          ),
          Divider(
            color: Colors.grey
          ),
        ],
      ),
    );
  }
}
