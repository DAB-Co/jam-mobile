import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jam/providers/user_provider.dart';

Widget goBackDialog(context) {
  return AlertDialog(
    title: Text('Do you want to exit?'),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('No'),
      ),
      TextButton(
        onPressed: () {
          SystemNavigator.pop();
        },
        child: Text('Yes'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          logout();
        },
        child: Text('Logout'),
      ),
    ],
  );
}
