import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
              FutureBuilder(future: PackageInfo.fromPlatform(),
                builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Text("");
                    default:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else if (snapshot.data == null)
                        return Text("");
                      else {
                        return Text(
                          snapshot.data!.version,
                          style: TextStyle(fontSize: 30),
                        );
                      }
                  }
                },
              ),
              SizedBox(height: 50),
              GestureDetector(
                onTap: _launchEmail,
                child: FittedBox(
                  child: Text(
                    "dabco5317@gmail.com",
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
    var _url = "mailto:dabco5317@gmail.com?subject=Jam";
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
}
