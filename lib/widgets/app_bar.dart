import 'package:flutter/material.dart';
import '../main.dart';
import '/config/routes.dart' as routes;

void handleThreeDotClick(String value) {
  switch (value) {
    case 'About':
      navigatorKey.currentState?.pushNamed(routes.about);
      break;
  }
}

AppBar formAppBar() {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.pinkAccent,
    title: Text("Jam"),
    actions: <Widget>[
      PopupMenuButton<String>(
        onSelected: handleThreeDotClick,
        itemBuilder: (BuildContext context) {
          return {'About'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),
    ],
    elevation: 0.1,
  );
}