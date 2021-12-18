import 'package:flutter/material.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '/config/routes.dart' as routes;

showLogoutAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Go back"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: Text("Log out"),
    onPressed: () {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, routes.login);
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

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
