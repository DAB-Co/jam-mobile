import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

const PIC_QUALITY = 25;

/// Compress file and get file.
Future<File?> compressAndGetFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    quality: PIC_QUALITY,
  );
  return result;
}

/// Compress byte list and get file.
Future<File?> compressBytesAndGetFile(Uint8List bytes, String targetPath) async {
  Uint8List compressed = await FlutterImageCompress.compressWithList(
    bytes,
    quality: PIC_QUALITY,
    format: CompressFormat.png,
  );
  return File(targetPath).writeAsBytes(compressed);
}

Future<String> getOriginalProfilePicPath(String id) async {
  Directory dir = await getApplicationDocumentsDirectory();
  String path = dir.path;
  return "$path/pp_$id.jpg";
}

Future<String> getSmallProfilePicPath(String id) async {
  Directory dir = await getApplicationDocumentsDirectory();
  String path = dir.path;
  return "$path/small_pp_$id.jpg";
}
