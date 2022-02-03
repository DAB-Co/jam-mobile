import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jam/widgets/form_widgets.dart';
import 'package:jam/widgets/show_snackbar.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(""),
        elevation: 0.1,
      ),
      body: Column(
      children: [
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            "Please send us your ideas and suggestions",
            style: TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: TextField(
              minLines: 12,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: longButtons("Send", () => {showSnackBar(context, "pressed")}),
        ),
      ],
      ),
    );
  }
}
