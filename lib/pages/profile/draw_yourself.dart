import 'package:flutter/material.dart';

class DrawYourself extends StatefulWidget {
  @override
  State<DrawYourself> createState() => _DrawYourselfState();
}

class _DrawYourselfState extends State<DrawYourself> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Draw Your Profile Picture"),
        elevation: 0.1,
      ),
    );
  }
}