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

abstract final class QrFerryMotion {
  static const quick = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 280);
  static const entrance = Duration(milliseconds: 440);
  static const slow = Duration(milliseconds: 620);

  static const Curve emphasized = Cubic(0.16, 1, 0.3, 1);
  static const Curve standardCurve = Curves.easeOutCubic;
}

class MotionReveal extends StatefulWidget {
  const MotionReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = QrFerryMotion.entrance,
    this.offsetY = 12,
    this.scaleFrom = 0.992,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final double scaleFrom;

  @override
  State<MotionReveal> createState() => _MotionRevealState();
}

class _MotionRevealState extends State<MotionReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: QrFerryMotion.emphasized,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.value = 1;
      return;
    }

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final value = _animation.value;
        final scale = widget.scaleFrom + ((1 - widget.scaleFrom) * value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - value)),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
    this.pressedScale = 0.988,
    this.pressedOffset = 2,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool enabled;
  final double pressedScale;
  final double pressedOffset;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
      onTapCancel: widget.enabled ? () => _setPressed(false) : null,
      onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: QrFerryMotion.quick,
        curve: QrFerryMotion.emphasized,
        child: AnimatedContainer(
          duration: QrFerryMotion.quick,
          curve: QrFerryMotion.emphasized,
          transform: Matrix4.translationValues(
            0,
            _pressed ? widget.pressedOffset : 0,
            0,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({
    super.key,
    this.color = QrFerryDesign.signal,
    this.size = 7,
    this.active = true,
  });

  final Color color;
  final double size;
  final bool active;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant PulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncAnimation();
  }

  void _syncAnimation() {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.active && !reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glow = widget.active ? 3 + (_pulse.value * 4) : 0.0;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.22),
                      spreadRadius: glow,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}

class SmoothProgress extends StatelessWidget {
  const SmoothProgress({
    super.key,
    required this.value,
    this.height = 6,
    this.foreground = QrFerryDesign.signal,
    this.background = const Color(0xFFE6E7E4),
    this.duration = const Duration(milliseconds: 220),
  });

  final double value;
  final double height;
  final Color foreground;
  final Color background;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: background),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: QrFerryMotion.standardCurve,
                    width: constraints.maxWidth * progress,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MotionSwitcher extends StatelessWidget {
  const MotionSwitcher({
    super.key,
    required this.child,
    this.duration = QrFerryMotion.standard,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: QrFerryMotion.emphasized,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: child,
    );
  }
}

class PaperGrid extends StatelessWidget {
  const PaperGrid({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _PaperGridPainter(),
      child: MotionReveal(
        duration: const Duration(milliseconds: 360),
        offsetY: 7,
        scaleFrom: 0.998,
        child: child,
      ),
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
    return MotionReveal(
      duration: const Duration(milliseconds: 520),
      offsetY: 4,
      scaleFrom: 0.88,
      child: SizedBox(
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
    return MotionReveal(
      duration: const Duration(milliseconds: 340),
      offsetY: 5,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
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
    return MotionReveal(
      child: Container(
        decoration: BoxDecoration(
          color: QrFerryDesign.ink,
          border: Border.all(color: QrFerryDesign.ink),
        ),
        padding: EdgeInsets.only(right: shadowOffset, bottom: shadowOffset),
        child: AnimatedSize(
          duration: QrFerryMotion.standard,
          curve: QrFerryMotion.emphasized,
          alignment: Alignment.topCenter,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: borderColor),
            ),
            child: child,
          ),
        ),
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
    return MotionReveal(
      duration: const Duration(milliseconds: 390),
      offsetY: 8,
      child: Row(
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
      ),
    );
  }
}
