import 'package:flutter/material.dart';

class About extends StatelessWidget {
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
              "Jam",
              style: TextStyle(fontSize: 50),
            ),
            Text(
              "1.0.0",
              style: TextStyle(fontSize: 30),
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
