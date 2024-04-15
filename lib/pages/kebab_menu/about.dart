import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Jam",
                style: TextStyle(fontSize: 50),
              ),
              SizedBox(height: 50),
              GestureDetector(
                onTap: _launchEmail,
                child: FittedBox(
                  child: Text(
                    "overlapco0@gmail.com",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchEmail() async {
    var _url = "mailto:overlapco0@gmail.com?subject=Jam";
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
}
