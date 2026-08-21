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
          title: const Text('Send', style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            if (transfer != null)
              TextButton(
                onPressed: controller.pickFile,
                child: const Text('CHANGE FILE'),
              ),
          ],
        ),
        body: PaperGrid(
          child: SafeArea(
            top: false,
            child: transfer == null ? _emptyState() : _transferState(transfer),
          ),
        ),
      );
    });
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        const TechLabel('Air-gapped file transfer'),
        const SizedBox(height: 18),
        const Text(
          'Move a file\nthrough the camera.',
          style: TextStyle(
            color: QrFerryDesign.ink,
            fontSize: 52,
            height: 0.9,
            fontWeight: FontWeight.w900,
            letterSpacing: -3.5,
          ),
        ),
        const SizedBox(height: 32),
        HardShadowBox(
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFA7AAA9), style: BorderStyle.solid),
                  color: QrFerryDesign.ink.withValues(alpha: 0.018),
                ),
                child: Column(
                  children: [
                    if (controller.preparing.value)
                      const CircularProgressIndicator(color: QrFerryDesign.ink)
                    else
                      InkWell(
                        onTap: controller.pickFile,
                        child: Container(
                          padding: const EdgeInsets.only(right: 3, bottom: 3),
                          color: QrFerryDesign.ink,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            color: Colors.white,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('＋', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 8),
                                Text('Browse files', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    Text(
                      'up to ${TransferEncoder.maxFileBytes ~/ (1024 * 1024)} MB',
                      style: const TextStyle(color: QrFerryDesign.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (controller.error.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0EB),
                    border: Border(left: BorderSide(color: QrFerryDesign.red, width: 3)),
                  ),
                  child: Text(controller.error.value!, style: const TextStyle(color: Color(0xFF842F21), fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _transferState(PreparedTransfer transfer) {
    final currentFrame = transfer.frameAt(controller.frameIndex.value);
    final progress = (controller.frameIndex.value + 1) / transfer.chunkCount;

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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: QrFerryDesign.darkStage,
                  border: Border.all(color: const Color(0xFF35404C)),
                ),
                child: Stack(
                  children: [
                    BinaryQrView(data: currentFrame, padding: 12),
                    const Positioned(top: 0, left: 0, child: _Corner(top: true, left: true)),
                    const Positioned(bottom: 0, right: 0, child: _Corner(top: false, left: false)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: controller.playing.value ? QrFerryDesign.signal : QrFerryDesign.muted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.playing.value ? 'Broadcasting' : 'Ready to broadcast',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${controller.fps.value} FPS',
                    style: const TextStyle(color: Color(0xFF909AA4), fontFamily: 'monospace', fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: QrFerryDesign.darkInset,
                  border: Border.all(color: const Color(0xFF35404C)),
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
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${controller.frameIndex.value + 1} / ${transfer.chunkCount}',
                          style: const TextStyle(color: Color(0xFF909AA4), fontFamily: 'monospace', fontSize: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRect(
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: const Color(0xFF303A44),
                        valueColor: const AlwaysStoppedAnimation(QrFerryDesign.signal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.togglePlayback,
                  icon: Icon(controller.playing.value ? Icons.pause : Icons.play_arrow),
                  label: Text(controller.playing.value ? 'Pause stream' : 'Start QR stream'),
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
        ...[5, 8, 12].map((fps) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PresetRow(
                fps: fps,
                selected: controller.fps.value == fps,
                onTap: () => controller.setFps(fps),
              ),
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: QrFerryDesign.line),
          ),
          child: Row(
            children: [
              Container(width: 35, height: 40, color: QrFerryDesign.blue, child: const Icon(Icons.arrow_upward, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transfer.filename, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.bytes(transfer.originalSize)}${transfer.compressed ? ' → ${Formatters.bytes(transfer.transmittedSize)}' : ''} · loops ${controller.loops.value}',
                      style: const TextStyle(color: QrFerryDesign.muted, fontFamily: 'monospace', fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.fps, required this.selected, required this.onTap});
  final int fps;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          border: Border.all(color: selected ? QrFerryDesign.ink : QrFerryDesign.line),
        ),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: QrFerryDesign.ink, width: selected ? 4 : 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fps == 5 ? 'Robust' : fps == 8 ? 'Balanced' : 'Turbo',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
            Text('$fps FPS', style: const TextStyle(color: QrFerryDesign.muted, fontFamily: 'monospace', fontSize: 9)),
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
    final p = Paint()..color = QrFerryDesign.signal..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height); path.lineTo(0, 0); path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
