import 'package:flutter/material.dart';

import '/config/routes.dart' as routes;

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Messages"),
        elevation: 0.1,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15, top: 5, bottom: 5),
            child: Image(
              image: AssetImage("assets/avatar.png"),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: ListTile(
            leading: Image(
              image: AssetImage("assets/avatar.png"),
            ),
            title: Text('User $index'),
            subtitle: Text("hey"),
            onTap: () {
              Navigator.pushNamed(context, routes.dm);
            },
          ),
        ),
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey,
        ),
        itemCount: 20,
      ),
    );
  }
}
