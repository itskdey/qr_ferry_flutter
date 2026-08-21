import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

class BinaryQrView extends StatelessWidget {
  const BinaryQrView({super.key, required this.data, this.padding = 18});

  final Uint8List data;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final qrCode = QrCode(
      payload: QrPayload.fromTypedData(data),
      errorCorrectLevel: QrErrorCorrectLevel.low,
    );
    final qrImage = QrImage(qrCode);

    return AspectRatio(
      aspectRatio: 1,
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: CustomPaint(
            painter: _QrPainter(qrImage),
            isComplex: true,
            willChange: true,
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final moduleCount = image.moduleCount;
    final cell = size.shortestSide / moduleCount;
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    for (var row = 0; row < moduleCount; row++) {
      for (var column = 0; column < moduleCount; column++) {
        if (!image.isDark(row, column)) continue;

        final left = column * cell;
        final top = row * cell;

        canvas.drawRect(
          Rect.fromLTRB(
            left.floorToDouble(),
            top.floorToDouble(),
            ((column + 1) * cell).ceilToDouble(),
            ((row + 1) * cell).ceilToDouble(),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
