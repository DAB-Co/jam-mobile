import 'package:flutter/material.dart';
import 'package:jam/config/routes.dart';

class Explanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
      color: Colors.white,
      fontSize: 20,
    );
    return Scaffold(
      backgroundColor: Color(0xFFFF66C4),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 70, bottom: 70, left: 50, right: 50),
        child: Column(
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/icon/icon.png'),
                ),
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "\tWelcome to Jam! This is an app that matches people with the same favorite colors. The matches are made daily at the same time for everyone so you won't get a match until midnight GMT. We will send a notification to remind you. Have fun!",
                    style: style,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: RawMaterialButton(
                  splashColor: Colors.white,
                  shape: CircleBorder(),
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.check,
                    color: Colors.grey,
                    size: 50,
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      chatLanguages,
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
