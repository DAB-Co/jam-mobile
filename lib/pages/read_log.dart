import 'package:flutter/material.dart';
import 'package:jam/util/log_to_file.dart';

class ReadLog extends StatefulWidget {
  @override
  State<ReadLog> createState() => _ReadLogState();
}

class _ReadLogState extends State<ReadLog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logs"),
      ),
      body: FutureBuilder(
        future: readLog(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return Text(snapshot.data as String);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            clearLog();
          });
        },
        child: Text("Clear"),
      ),
    );
  }
}
