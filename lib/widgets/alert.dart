import 'package:flutter/material.dart';
import 'package:jam/main.dart';

Widget cancelButton = TextButton(
  child: Text("Cancel"),
  onPressed: () {
    navigatorKey.currentState?.pop();
  },
);

AlertDialog alert(String title, TextButton continueButton, {content: Widget}) {
  return AlertDialog(
    title: Text(title),
    content: content,
    actions: [
      cancelButton,
      continueButton,
    ],
  );
}
