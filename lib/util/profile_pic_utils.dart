import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:jam/models/user.dart';
import 'package:jam/network/update_profile_pic.dart';
import 'package:path_provider/path_provider.dart';

const PIC_QUALITY = 25;
const SMALL_PIC_WIDTH = 100;
const SMALL_PIC_HEIGHT = 100;
const BIG_PIC_WIDTH = 400;
const BIG_PIC_HEIGHT = 400;

/// Copies given byte list to profile picture path of user and compresses it
/// Returns true if network call is successful
Future<bool> saveOwnPictureFromByteList(Uint8List bytes, User user) async {
  // compress
  Uint8List compressed = await FlutterImageCompress.compressWithList(
    bytes,
    quality: PIC_QUALITY,
    format: CompressFormat.jpeg,
    minWidth: BIG_PIC_WIDTH,
    minHeight: BIG_PIC_HEIGHT,
  );

  // compress to thumbnail
  Uint8List thumbnail = await createThumbnail(compressed);

  // send pictures to server
  bool networkCallSuccess =
      await updateProfilePicCall(user, compressed, thumbnail);
  if (!networkCallSuccess) return false;

  saveOwnPictures(thumbnail, compressed, user.id!);
  return true;
}

Future saveOwnPictures(Uint8List small, Uint8List big, String userId) async {
  // save pictures to local storage
  String path = await getOriginalProfilePicPath(userId);
  String thumbnailPath = await getSmallProfilePicPath(userId);

  await File(path).writeAsBytes(big);
  await File(thumbnailPath).writeAsBytes(small);

  // clear image cache, IMPORTANT
  _clearImageCache();
}

Future saveBothPictures(Uint8List image, String userId) async {
  Uint8List thumbnail = await createThumbnail(image);
  saveOwnPictures(thumbnail, image, userId);
}

Future saveBigPicture(Uint8List bytes, String userId) async {
  String path = await getOriginalProfilePicPath(userId);
  File oldImage = File(path);
  if (!oldImage.existsSync() || await oldImage.readAsBytes() != bytes) {
    await File(path).writeAsBytes(bytes);
    _clearImageCache();
  }
}

Future saveSmallPicture(Uint8List bytes, String userId) async {
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
  String smallPath = await getSmallProfilePicPath(id);
  File original = File(path);
  File small = File(smallPath);
  if (original.existsSync()) {
    try {
      await original.delete();
      _clearImageCache();
    } catch (err) {
      print(err);
    }
  }
  if (small.existsSync()) {
    try {
      await small.delete();
      _clearImageCache();
    } catch (err) {
      print(err);
    }
  }
}

Future deleteSmallPicture(String id) async {
  String smallPath = await getSmallProfilePicPath(id);
  File small = File(smallPath);
  if (small.existsSync()) {
    try {
      await small.delete();
      _clearImageCache();
    } catch (err) {
      print(err);
    }
  }
}

void _clearImageCache() {
  imageCache?.clear();
  imageCache?.clearLiveImages();
}

Future<Uint8List> createThumbnail(Uint8List image) async {
  return await FlutterImageCompress.compressWithList(
    image,
    quality: PIC_QUALITY,
    format: CompressFormat.jpeg,
    minWidth: SMALL_PIC_WIDTH,
    minHeight: SMALL_PIC_HEIGHT,
  );
}
