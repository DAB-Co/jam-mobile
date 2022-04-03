import 'package:flutter/material.dart';

class DrawYourself extends StatefulWidget {
  @override
  State<DrawYourself> createState() => _DrawYourselfState();
}

class _DrawYourselfState extends State<DrawYourself> {
  List<Offset?> _points = <Offset?>[];

  @override
  Widget build(BuildContext context) {
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
              print(localPosition);
            });
          },
          onPanEnd: (DragEndDetails details) => _points.add(null),
          child: new CustomPaint(painter: new SignaturePainter(_points)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
