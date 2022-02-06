import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/log.txt');
}

Future<File> logToFile(String log) async {
  final file = await _localFile;
  // Write the file
  return file.writeAsString('$log', mode: FileMode.append);
}

Future<String> readLog() async {
  try {
    final file = await _localFile;
    // Read the file
    final contents = await file.readAsString();
    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "An error occured: ${e.toString()}";
  }
}

Future clearLog() async {
  final file = await _localFile;
  file.writeAsString("");
}
