import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

const PIC_QUALITY = 25;
const SMALL_PIC_WIDTH = 50;
const SMALL_PIC_HEIGHT = 50;

/// Copies given file to profile picture path of user and compresses it.
/// Also saves small version of given picture in small picture path
Future savePicture(XFile? image, String id) async {
  if (image == null) return;
  // copy the file to a new path
  File imageFile = File(image.path);
  String path = await getOriginalProfilePicPath(id);
  String thumbnailPath = await getSmallProfilePicPath(id);
  await Future.wait([
    _compressAndGetFile(imageFile, path),
    _compressAndGetSmallFile(imageFile, thumbnailPath),
  ]);
  // clear image cache, IMPORTANT
  _clearImageCache();
}

/// Copies given byte list to profile picture path of user and compresses it
Future savePictureFromByteList(Uint8List bytes, String id) async {
  String path = await getOriginalProfilePicPath(id);
  String thumbnailPath = await getSmallProfilePicPath(id);
  await Future.wait([
    _compressBytesAndGetFile(bytes, path),
    _compressBytesAndGetSmallFile(bytes, thumbnailPath),
  ]);
  // clear image cache, IMPORTANT
  _clearImageCache();
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

Future deleteProfilePicture(String id) async {
  String path = await getOriginalProfilePicPath(id);
  await File(path).delete();
}

/// Compress file and get file.
Future<File?> _compressAndGetFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: PIC_QUALITY,
  );
  return result;
}

/// Compress file and get file.
Future<File?> _compressAndGetSmallFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: PIC_QUALITY,
    minWidth: SMALL_PIC_WIDTH,
    minHeight: SMALL_PIC_HEIGHT,
  );
  return result;
}

/// Compress byte list and get file.
Future<File?> _compressBytesAndGetFile(
    Uint8List bytes, String targetPath) async {
  Uint8List compressed = await FlutterImageCompress.compressWithList(
    bytes,
    quality: PIC_QUALITY,
    format: CompressFormat.png,
  );
  return File(targetPath).writeAsBytes(compressed);
}

/// Compress byte list and get file.
Future<File?> _compressBytesAndGetSmallFile(
    Uint8List bytes, String targetPath) async {
  Uint8List compressed = await FlutterImageCompress.compressWithList(
    bytes,
    quality: PIC_QUALITY,
    format: CompressFormat.png,
    minWidth: SMALL_PIC_WIDTH,
    minHeight: SMALL_PIC_HEIGHT,
  );
  return File(targetPath).writeAsBytes(compressed);
}

void _clearImageCache() {
  imageCache?.clear();
  imageCache?.clearLiveImages();
}
