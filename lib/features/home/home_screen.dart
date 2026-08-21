import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/qrferry_design.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _headerHeight = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperGrid(
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  _headerHeight + 58,
                  24,
                  40,
                ),
                children: [
                  _Stagger.build(
                    index: 0,
                    child: const TechLabel('Air-gapped file transfer'),
                  ),
                  const SizedBox(height: 18),
                  _Stagger.build(
                    index: 1,
                    offsetY: 18,
                    child: const Text(
                      'Move a file\nthrough the camera.',
                      style: TextStyle(
                        color: QrFerryDesign.ink,
                        fontSize: 56,
                        height: 0.9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -4.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Stagger.build(
                    index: 2,
                    child: const Text(
                      'No Wi-Fi, Bluetooth, cloud, account, or pairing. Your file '
                      'stays on your devices while animated QR frames carry the '
                      'bytes.',
                      style: TextStyle(
                        color: Color(0xFF3B444C),
                        fontSize: 16,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Stagger.build(
                    index: 3,
                    child: const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TrustChip('Local only'),
                        _TrustChip('Binary QR'),
                        _TrustChip('CRC verified'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 42),
                  _Stagger.build(
                    index: 4,
                    child: _ActionBlock(
                      number: '01',
                      title: 'Send a file',
                      subtitle:
                          'Turn any local file into a repeating optical stream.',
                      icon: Icons.arrow_upward_rounded,
                      dark: false,
                      onTap: () => Get.toNamed<void>(AppRoutes.send),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Stagger.build(
                    index: 5,
                    child: _ActionBlock(
                      number: '02',
                      title: 'Receive a file',
                      subtitle:
                          'Point the camera at the sender and rebuild it locally.',
                      icon: Icons.center_focus_strong_rounded,
                      dark: true,
                      onTap: () => Get.toNamed<void>(AppRoutes.receive),
                    ),
                  ),
                  const SizedBox(height: 46),
                  _Stagger.build(
                    index: 6,
                    child: const Divider(color: QrFerryDesign.ink, height: 1),
                  ),
                  const SizedBox(height: 28),
                  _Stagger.build(
                    index: 7,
                    child: const TechLabel('Private by transport'),
                  ),
                  const SizedBox(height: 12),
                  _Stagger.build(
                    index: 8,
                    child: const _MonoCaption(
                      'The QR stream is the transport channel itself. Nothing '
                      'needs to be uploaded to an application server.',
                      color: QrFerryDesign.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Positioned(top: 0, left: 0, right: 0, child: _Header()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centralizes the staggered entrance timing so delays don't have to be
/// hand-tuned and renumbered every time a section is inserted or reordered.
class _Stagger {
  static const Duration _base = Duration(milliseconds: 60);
  static const Duration _step = Duration(milliseconds: 50);

  static Widget build({
    required int index,
    required Widget child,
    double offsetY = 0,
  }) {
    final delay = _base + _step * index;
    return MotionReveal(delay: delay, offsetY: offsetY, child: child);
  }
}

/// Shared style for small muted monospace captions/labels, previously
/// duplicated across the trust chips, header status text, and footer copy.
class _MonoCaption extends StatelessWidget {
  const _MonoCaption(
    this.text, {
    required this.color,
    this.fontSize = 9,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 0.5,
    this.height,
    this.uppercase = false,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double? height;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Text(
      uppercase ? text.toUpperCase() : text,
      style: TextStyle(
        color: color,
        fontFamily: 'monospace',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: HomeScreen._headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: QrFerryDesign.paper.withValues(alpha: 0.98),
        border: const Border(
          bottom: BorderSide(color: QrFerryDesign.line, width: 1),
        ),
      ),
      child: _Stagger.build(
        index: 0,
        child: Row(
          children: [
            const Text(
              'QRFerry',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
            const Spacer(),
            Semantics(
              button: true,
              label: 'Open QRFerry project details',
              child: Pressable(
                onTap: () => Get.toNamed<void>(AppRoutes.details),
                pressedScale: 0.96,
                pressedOffset: 1,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DETAILS',
                      style: TextStyle(
                        color: QrFerryDesign.muted,
                        fontFamily: 'monospace',
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    SizedBox(width: 8),
                    _DetailsArrow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsArrow extends StatelessWidget {
  const _DetailsArrow();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi - math.pi / 4,
      child: const Icon(Icons.arrow_back, size: 20),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: QrFerryDesign.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: _MonoCaption(
        label,
        color: QrFerryDesign.muted,
        letterSpacing: 0.65,
        uppercase: true,
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.dark,
    required this.onTap,
  });

  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : QrFerryDesign.ink;
    final muted = dark ? const Color(0xFF98A0A8) : QrFerryDesign.muted;

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.99,
        pressedOffset: 3,
        child: HardShadowBox(
          color: dark ? const Color(0xFF0D1923) : const Color(0xFFFCFBF8),
          borderColor: QrFerryDesign.ink,
          // On the dark card, an ink-colored shadow blends into the near-
          // black fill and the offset depth cue disappears. Use the lime
          // accent instead so both cards read with the same visual weight.
          shadowColor: dark ? QrFerryDesign.signal : QrFerryDesign.ink,
          shadowOffset: 8,
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              ExcludeSemantics(
                child: _MonoCaption(number, color: muted, fontSize: 10),
              ),
              const SizedBox(width: 18),
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  color: dark ? QrFerryDesign.signal : QrFerryDesign.blue,
                  child: Icon(
                    icon,
                    color: dark ? QrFerryDesign.ink : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
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
              ExcludeSemantics(child: _AnimatedArrow(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extracted from inline `TweenAnimationBuilder` so `_ActionBlock.build()`
/// stays declarative. Note: as a `TweenAnimationBuilder` this still replays
/// on every parent rebuild, not just on first mount — swap for an
/// `AnimationController`-backed widget with a "played once" guard if that
/// becomes visible in practice (e.g. after `setState` elsewhere in the tree).
class _AnimatedArrow extends StatelessWidget {
  const _AnimatedArrow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: QrFerryMotion.emphasized,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(6 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Icon(Icons.arrow_forward_rounded, color: color),
    );
  }
}
