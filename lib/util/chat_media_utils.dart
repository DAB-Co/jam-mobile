import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

const PIC_QUALITY = 25;
const PIC_WIDTH = 400;
const PIC_HEIGHT = 400;

Future<Uint8List> compressChatImage(Uint8List bytes) async {
  while (true) {
    try {
      return await FlutterImageCompress.compressWithList(
        bytes,
        quality: PIC_QUALITY,
        format: CompressFormat.png,
        minWidth: PIC_WIDTH,
        minHeight: PIC_HEIGHT,
      );
    } catch (err) {
      print(err);
    }
  }
}

Future<String> saveChatImage(Uint8List bytes, String fromWhomUserId) async {
  Directory dir = await getApplicationDocumentsDirectory();
  String path = dir.path;
  String now = DateTime.now().toString();
  String imgPath = "$path/$now-$fromWhomUserId";
  await File(imgPath).writeAsBytes(bytes);
  imageCache.clear();
  imageCache.clearLiveImages();
  return imgPath;
}
