import 'package:flutter/material.dart';

Row loading(String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      CircularProgressIndicator(),
      Text(" " + text),
    ],
  );
}