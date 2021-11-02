import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black,
      // action: SnackBarAction(label: 'Dismiss', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}