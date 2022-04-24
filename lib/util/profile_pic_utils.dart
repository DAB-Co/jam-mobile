import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/update_profile_pic.dart';
import 'package:path_provider/path_provider.dart';

const PIC_QUALITY = 25;
const SMALL_PIC_WIDTH = 50;
const SMALL_PIC_HEIGHT = 50;

/// Copies given byte list to profile picture path of user and compresses it
/// Returns true if network call is successful
Future<bool> saveOwnPictureFromByteList(Uint8List bytes, User user) async {
  // compress
  Uint8List compressed = await FlutterImageCompress.compressWithList(
    bytes,
    quality: PIC_QUALITY,
    format: CompressFormat.png,
  );

  // compress to thumbnail
  Uint8List thumbnail = await FlutterImageCompress.compressWithList(
    bytes,
    quality: PIC_QUALITY,
    format: CompressFormat.png,
    minWidth: SMALL_PIC_WIDTH,
    minHeight: SMALL_PIC_HEIGHT,
  );

  // send pictures to server
  bool networkCallSuccess = await updateProfilePicCall(user, compressed, thumbnail);
  if (!networkCallSuccess) return false;

  // save pictures to local storage
  String path = await getOriginalProfilePicPath(user.id!);
  String thumbnailPath = await getSmallProfilePicPath(user.id!);

  await File(path).writeAsBytes(compressed);
  await File(thumbnailPath).writeAsBytes(thumbnail);

  // clear image cache, IMPORTANT
  _clearImageCache();
  return true;
}

Future saveOtherBigPictureFromByteList(Uint8List bytes, String userId) async {
  String path = await getOriginalProfilePicPath(userId);
  File oldImage = File(path);
  if (!oldImage.existsSync() || await oldImage.readAsBytes() != bytes) {
    await File(path).writeAsBytes(bytes);
    _clearImageCache();
  }
}

Future saveOtherSmallPictureFromByteList(Uint8List bytes, String userId) async {
  String path = await getSmallProfilePicPath(userId);
  File oldImage = File(path);
  if (!oldImage.existsSync() || await oldImage.readAsBytes() != bytes) {
    await File(path).writeAsBytes(bytes);
    _clearImageCache();
  }
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

void _clearImageCache() {
  imageCache?.clear();
  imageCache?.clearLiveImages();
}
