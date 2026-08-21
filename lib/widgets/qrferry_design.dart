import 'package:flutter/material.dart';

abstract final class QrFerryDesign {
  static const ink = Color(0xFF111820);
  static const paper = Color(0xFFF4F1EA);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFF667079);
  static const line = Color(0xFFD5D2CA);
  static const signal = Color(0xFFE7FF54);
  static const signalSoft = Color(0xFFF3FFAE);
  static const blue = Color(0xFF2F6DFF);
  static const red = Color(0xFFD44D36);
  static const darkPanel = Color(0xFF111820);
  static const darkStage = Color(0xFF202832);
  static const darkInset = Color(0xFF18212A);
}

class PaperGrid extends StatelessWidget {
  const PaperGrid({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _PaperGridPainter(),
      child: child,
    );
  }
}

class _PaperGridPainter extends CustomPainter {
  const _PaperGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = QrFerryDesign.paper);
    final paint = Paint()
      ..color = QrFerryDesign.ink.withValues(alpha: 0.027)
      ..strokeWidth = 1;
    const spacing = 28.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FerryBrandMark extends StatelessWidget {
  const FerryBrandMark({super.key, this.size = 25});
  final double size;

  @override
  Widget build(BuildContext context) {
    final gap = size * 0.12;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final cell in const [Offset(0, 0), Offset(1, 0), Offset(0, 1)])
            Positioned(
              left: cell.dx * (size / 2 + gap / 2),
              top: cell.dy * (size / 2 + gap / 2),
              child: Container(
                width: (size - gap) / 2,
                height: (size - gap) / 2,
                decoration: BoxDecoration(
                  border: Border.all(color: QrFerryDesign.ink, width: 3),
                ),
              ),
            ),
          Positioned(
            right: -2,
            bottom: 2,
            child: Container(
              width: (size - gap) / 2,
              height: (size - gap) / 2,
              color: QrFerryDesign.signal,
            ),
          ),
        ],
      ),
    );
  }
}

class TechLabel extends StatelessWidget {
  const TechLabel(this.text, {super.key, this.color = QrFerryDesign.muted});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color,
        fontFamily: 'monospace',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class HardShadowBox extends StatelessWidget {
  const HardShadowBox({
    super.key,
    required this.child,
    this.color = QrFerryDesign.white,
    this.padding = EdgeInsets.zero,
    this.shadowOffset = 8,
    this.borderColor = QrFerryDesign.ink,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double shadowOffset;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: QrFerryDesign.ink,
        border: Border.all(color: QrFerryDesign.ink),
      ),
      padding: EdgeInsets.only(right: shadowOffset, bottom: shadowOffset),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
        ),
        child: child,
      ),
    );
  }
}

class StepHeading extends StatelessWidget {
  const StepHeading({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    this.inverse = false,
  });

  final String number;
  final String title;
  final String subtitle;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final muted = inverse ? const Color(0xFF98A0A8) : QrFerryDesign.muted;
    final foreground = inverse ? Colors.white : QrFerryDesign.ink;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            number,
            style: TextStyle(
              color: muted,
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
