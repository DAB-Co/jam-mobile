import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(""),
        elevation: 0.1,
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Contact Us",
            style: TextStyle(fontSize: 50),
          ),
          SizedBox(height: 50),
          Text(
            "dabco5317@gmail.com",
            style: TextStyle(fontSize: 30),
          ),
        ],
      ),
      ),
    );
  }
}
