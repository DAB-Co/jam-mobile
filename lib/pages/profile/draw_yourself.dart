// https://stackoverflow.com/questions/50320479/flutter-how-would-one-save-a-canvas-custompainter-to-an-image-file

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jam/models/user.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/profile_pic_utils.dart';
import 'package:provider/provider.dart';

class DrawYourself extends StatefulWidget {
  @override
  State<DrawYourself> createState() => _DrawYourselfState();
}

class _DrawYourselfState extends State<DrawYourself> {
  List<Offset?> _points = <Offset?>[];

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user!;

    Future _saveToImage(List<Offset?> points) async {
      final recorder = new PictureRecorder();
      final canvas = new Canvas(recorder);
      Paint paint = new Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;

      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        }
      }

      final picture = recorder.endRecording();
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;
      final img = await picture.toImage(width.toInt(), height.toInt());
      final pngBytes = await img.toByteData(format: ImageByteFormat.png);
      if (pngBytes == null) return;
      Uint8List bytes = pngBytes.buffer
          .asUint8List(pngBytes.offsetInBytes, pngBytes.lengthInBytes);
      await savePictureFromByteList(bytes, user.id!);
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              RenderBox? referenceBox =
                  context.findRenderObject() as RenderBox?;
              Offset? localPosition =
                  referenceBox?.globalToLocal(details.globalPosition);
              _points = new List.from(_points)..add(localPosition);
            });
          },
          onPanEnd: (DragEndDetails details) => _points.add(null),
          child: new CustomPaint(painter: new SignaturePainter(_points)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _saveToImage(_points);
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  SignaturePainter(this.points);

  final List<Offset?> points;

  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null)
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
    }
  }

  bool shouldRepaint(SignaturePainter other) => other.points != points;
}
