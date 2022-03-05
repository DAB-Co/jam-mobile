import 'package:flutter/material.dart';

class ProfileOther extends StatefulWidget {
  const ProfileOther({required this.otherUsername, required this.otherId})
      : super();
  final String otherUsername;
  final String otherId;

  @override
  _ProfileOtherState createState() =>
      _ProfileOtherState(otherUsername: otherUsername, otherId: otherId);
}

class _ProfileOtherState extends State<ProfileOther> {
  _ProfileOtherState({required this.otherUsername, required this.otherId})
      : super();
  final String otherUsername;
  final String otherId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(otherUsername),
        elevation: 0.1,
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/avatar.png'),
              ),
            ),
          ),
          SizedBox(height: 30),
          Divider(color: Colors.grey),
          SizedBox(height: 30),
          const Text("Common songs etc. TODO..."),
        ],
      ),
    );
  }
}
