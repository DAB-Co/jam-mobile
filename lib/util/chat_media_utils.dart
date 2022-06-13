import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

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
      continue;
    }
  }
}
