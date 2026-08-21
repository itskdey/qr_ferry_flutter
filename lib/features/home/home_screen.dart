import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/qrferry_design.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperGrid(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            children: [
              const _Header(),
              const SizedBox(height: 58),
              const MotionReveal(
                delay: Duration(milliseconds: 60),
                child: TechLabel('Air-gapped file transfer'),
              ),
              const SizedBox(height: 18),
              const MotionReveal(
                delay: Duration(milliseconds: 110),
                offsetY: 18,
                child: Text(
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
              const MotionReveal(
                delay: Duration(milliseconds: 160),
                child: Text(
                  'No Wi-Fi, Bluetooth, cloud, account, or pairing. Your file stays on your devices while animated QR frames carry the bytes.',
                  style: TextStyle(
                    color: Color(0xFF3B444C),
                    fontSize: 16,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const MotionReveal(
                delay: Duration(milliseconds: 210),
                child: Wrap(
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
              MotionReveal(
                delay: const Duration(milliseconds: 260),
                child: _ActionBlock(
                  number: '01',
                  title: 'Send a file',
                  subtitle: 'Turn any local file into a repeating optical stream.',
                  icon: Icons.arrow_upward_rounded,
                  dark: false,
                  onTap: () => Get.toNamed<void>(AppRoutes.send),
                ),
              ),
              const SizedBox(height: 14),
              MotionReveal(
                delay: const Duration(milliseconds: 320),
                child: _ActionBlock(
                  number: '02',
                  title: 'Receive a file',
                  subtitle: 'Point the camera at the sender and rebuild it locally.',
                  icon: Icons.center_focus_strong_rounded,
                  dark: true,
                  onTap: () => Get.toNamed<void>(AppRoutes.receive),
                ),
              ),
              const SizedBox(height: 46),
              const MotionReveal(
                delay: Duration(milliseconds: 380),
                child: Divider(color: QrFerryDesign.ink, height: 1),
              ),
              const SizedBox(height: 28),
              const MotionReveal(
                delay: Duration(milliseconds: 420),
                child: TechLabel('Private by transport'),
              ),
              const SizedBox(height: 12),
              const MotionReveal(
                delay: Duration(milliseconds: 450),
                child: Text(
                  'The QR stream is the transport channel itself. Nothing needs to be uploaded to an application server.',
                  style: TextStyle(
                    color: QrFerryDesign.muted,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: QrFerryDesign.line)),
        ),
        child: Row(
          children: [
            const FerryBrandMark(),
            const SizedBox(width: 11),
            const MotionReveal(
              delay: Duration(milliseconds: 40),
              child: Text(
                'QRFerry',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            const Spacer(),
            const PulseDot(color: Color(0xFF44A766), size: 7),
            const SizedBox(width: 8),
            const MotionReveal(
              delay: Duration(milliseconds: 80),
              child: Text(
                'DEVICE TO DEVICE',
                style: TextStyle(
                  color: QrFerryDesign.muted,
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
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
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: QrFerryDesign.muted,
          fontFamily: 'monospace',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.65,
        ),
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

    return Pressable(
      onTap: onTap,
      pressedScale: 0.99,
      pressedOffset: 3,
      child: HardShadowBox(
        color: dark ? QrFerryDesign.ink : const Color(0xFFFCFBF8),
        shadowOffset: 7,
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Text(
              number,
              style: TextStyle(
                color: muted,
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 18),
            Container(
              width: 48,
              height: 48,
              color: dark ? QrFerryDesign.signal : QrFerryDesign.blue,
              child: Icon(icon, color: dark ? QrFerryDesign.ink : Colors.white),
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
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: QrFerryMotion.emphasized,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(6 * (1 - value), 0),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Icon(Icons.arrow_forward_rounded, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
