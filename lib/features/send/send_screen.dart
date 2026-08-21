import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/protocol/transfer_encoder.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/binary_qr_view.dart';
import '../../widgets/qrferry_design.dart';
import 'send_controller.dart';

class SendScreen extends GetView<SendController> {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final transfer = controller.transfer.value;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Send',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: [
            if (transfer != null)
              MotionReveal(
                child: TextButton(
                  onPressed: controller.pickFile,
                  child: const Text('CHANGE FILE'),
                ),
              ),
          ],
        ),
        body: PaperGrid(
          child: SafeArea(
            top: false,
            child: MotionSwitcher(
              duration: const Duration(milliseconds: 360),
              child: KeyedSubtree(
                key: ValueKey(transfer == null ? 'empty' : 'transfer'),
                child: transfer == null
                    ? _emptyState()
                    : _transferState(transfer),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        const MotionReveal(
          delay: Duration(milliseconds: 50),
          child: TechLabel('Air-gapped file transfer'),
        ),
        const SizedBox(height: 18),
        const MotionReveal(
          delay: Duration(milliseconds: 100),
          offsetY: 18,
          child: Text(
            'Move a file\nthrough the camera.',
            style: TextStyle(
              color: QrFerryDesign.ink,
              fontSize: 52,
              height: 0.9,
              fontWeight: FontWeight.w900,
              letterSpacing: -3.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
        MotionReveal(
          delay: const Duration(milliseconds: 160),
          child: HardShadowBox(
            color: const Color(0xFFFCFBF8),
            shadowOffset: 9,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StepHeading(
                  number: '01',
                  title: 'Choose a file',
                  subtitle: 'Compression and encoding stay on this device.',
                ),
                const SizedBox(height: 24),
                AnimatedContainer(
                  duration: QrFerryMotion.standard,
                  curve: QrFerryMotion.emphasized,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 34,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFA7AAA9)),
                    color: controller.preparing.value
                        ? QrFerryDesign.signal.withValues(alpha: 0.08)
                        : QrFerryDesign.ink.withValues(alpha: 0.018),
                  ),
                  child: Column(
                    children: [
                      MotionSwitcher(
                        child: controller.preparing.value
                            ? const SizedBox(
                                key: ValueKey('preparing'),
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: QrFerryDesign.ink,
                                ),
                              )
                            : Pressable(
                                key: const ValueKey('browse'),
                                onTap: controller.pickFile,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    right: 3,
                                    bottom: 3,
                                  ),
                                  color: QrFerryDesign.ink,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 13,
                                    ),
                                    color: Colors.white,
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('＋', style: TextStyle(fontSize: 18)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Browse files',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'up to ${TransferEncoder.maxFileBytes ~/ (1024 * 1024)} MB',
                        style: const TextStyle(
                          color: QrFerryDesign.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: QrFerryMotion.standard,
                  curve: QrFerryMotion.emphasized,
                  child: controller.error.value == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: MotionReveal(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF0EB),
                                border: Border(
                                  left: BorderSide(
                                    color: QrFerryDesign.red,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Text(
                                controller.error.value!,
                                style: const TextStyle(
                                  color: Color(0xFF842F21),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _transferState(PreparedTransfer transfer) {
    final currentFrame = transfer.frameAt(controller.frameIndex.value);
    final progress = (controller.frameIndex.value + 1) / transfer.chunkCount;
    final playing = controller.playing.value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        HardShadowBox(
          shadowOffset: 10,
          color: QrFerryDesign.ink,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepHeading(
                number: '03',
                title: 'Play the QR stream',
                subtitle: 'Keep the complete code inside the receiver guide.',
                inverse: true,
              ),
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: QrFerryMotion.standard,
                curve: QrFerryMotion.emphasized,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: QrFerryDesign.darkStage,
                  border: Border.all(
                    color: playing
                        ? QrFerryDesign.signal.withValues(alpha: 0.68)
                        : const Color(0xFF35404C),
                  ),
                  boxShadow: playing
                      ? [
                          BoxShadow(
                            color: QrFerryDesign.signal.withValues(alpha: 0.07),
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    // QR frames intentionally switch immediately. Tweening the
                    // actual code can create unreadable intermediate frames.
                    BinaryQrView(data: currentFrame, padding: 12),
                    const Positioned(
                      top: 0,
                      left: 0,
                      child: _Corner(top: true, left: true),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: _Corner(top: false, left: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  PulseDot(
                    color: playing
                        ? QrFerryDesign.signal
                        : QrFerryDesign.muted,
                    active: playing,
                    size: 7,
                  ),
                  const SizedBox(width: 8),
                  MotionSwitcher(
                    child: Text(
                      playing ? 'Broadcasting' : 'Ready to broadcast',
                      key: ValueKey(playing),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedDefaultTextStyle(
                    duration: QrFerryMotion.standard,
                    curve: QrFerryMotion.emphasized,
                    style: TextStyle(
                      color: playing
                          ? QrFerryDesign.signal
                          : const Color(0xFF909AA4),
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: playing ? FontWeight.w800 : FontWeight.w400,
                    ),
                    child: Text('${controller.fps.value} FPS'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AnimatedContainer(
                duration: QrFerryMotion.standard,
                curve: QrFerryMotion.emphasized,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: QrFerryDesign.darkInset,
                  border: Border.all(
                    color: playing
                        ? const Color(0xFF46535E)
                        : const Color(0xFF35404C),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transfer.filename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 140),
                          child: Text(
                            '${controller.frameIndex.value + 1} / ${transfer.chunkCount}',
                            key: ValueKey(controller.frameIndex.value),
                            style: const TextStyle(
                              color: Color(0xFF909AA4),
                              fontFamily: 'monospace',
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SmoothProgress(
                      value: progress,
                      height: 5,
                      foreground: QrFerryDesign.signal,
                      background: const Color(0xFF303A44),
                      duration: const Duration(milliseconds: 120),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Text(
                          'SESSION ${_sessionCode(transfer.session)}',
                          style: const TextStyle(
                            color: QrFerryDesign.signal,
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'FQR1 · BINARY QR',
                          style: TextStyle(
                            color: Color(0xFF7E8993),
                            fontFamily: 'monospace',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Pressable(
                onTap: controller.togglePlayback,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.togglePlayback,
                    icon: MotionSwitcher(
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        key: ValueKey(playing),
                      ),
                    ),
                    label: MotionSwitcher(
                      child: Text(
                        playing ? 'Pause stream' : 'Start QR stream',
                        key: ValueKey(playing),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const StepHeading(
          number: '02',
          title: 'Tune the channel',
          subtitle: 'Lower the frame rate when the receiver struggles to lock.',
        ),
        const SizedBox(height: 16),
        ...[5, 8, 12].map(
          (fps) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PresetRow(
              fps: fps,
              selected: controller.fps.value == fps,
              onTap: () => controller.setFps(fps),
            ),
          ),
        ),
        const SizedBox(height: 12),
        MotionReveal(
          delay: const Duration(milliseconds: 80),
          child: AnimatedContainer(
            duration: QrFerryMotion.standard,
            curve: QrFerryMotion.emphasized,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: QrFerryDesign.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 40,
                  color: QrFerryDesign.blue,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.filename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: QrFerryMotion.quick,
                        child: Text(
                          '${Formatters.bytes(transfer.originalSize)}${transfer.compressed ? ' → ${Formatters.bytes(transfer.transmittedSize)}' : ''} · loops ${controller.loops.value}',
                          key: ValueKey(controller.loops.value),
                          style: const TextStyle(
                            color: QrFerryDesign.muted,
                            fontFamily: 'monospace',
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const MotionReveal(
          delay: Duration(milliseconds: 140),
          child: _ProtocolStrip(),
        ),
      ],
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.fps,
    required this.selected,
    required this.onTap,
  });

  final int fps;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.994,
      pressedOffset: 1.5,
      child: AnimatedContainer(
        duration: QrFerryMotion.standard,
        curve: QrFerryMotion.emphasized,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          border: Border.all(
            color: selected ? QrFerryDesign.ink : QrFerryDesign.line,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: QrFerryDesign.ink.withValues(alpha: 0.06),
                    offset: const Offset(2, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: QrFerryMotion.standard,
              curve: QrFerryMotion.emphasized,
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: selected ? QrFerryDesign.signal : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: QrFerryDesign.ink,
                  width: selected ? 3 : 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: QrFerryMotion.standard,
                style: TextStyle(
                  color: QrFerryDesign.ink,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                ),
                child: Text(
                  fps == 5 ? 'Robust' : fps == 8 ? 'Balanced' : 'Turbo',
                ),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: QrFerryMotion.standard,
              style: TextStyle(
                color: selected ? QrFerryDesign.ink : QrFerryDesign.muted,
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
              ),
              child: Text('$fps FPS'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.top, required this.left});

  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _CornerPainter(top: top, left: left)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.top, required this.left});

  final bool top;
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = QrFerryDesign.signal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (top && left) {
      path
        ..moveTo(0, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0);
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProtocolStrip extends StatelessWidget {
  const _ProtocolStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        border: Border.all(color: QrFerryDesign.line),
      ),
      child: const Text(
        'FQR1  ·  BINARY QR  ·  CRC32  ·  LOCAL ONLY',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: QrFerryDesign.muted,
          fontFamily: 'monospace',
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.65,
        ),
      ),
    );
  }
}

String _sessionCode(int sessionId) {
  final hex = sessionId
      .toUnsigned(32)
      .toRadixString(16)
      .padLeft(8, '0')
      .toUpperCase();
  return '${hex.substring(0, 4)}-${hex.substring(4)}';
}
