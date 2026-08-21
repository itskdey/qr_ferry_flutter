import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/utils/formatters.dart';
import '../../widgets/qrferry_design.dart';
import 'receive_controller.dart';

class ReceiveScreen extends GetView<ReceiveController> {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: controller.toggleTorch, icon: const Icon(Icons.flash_on_outlined)),
        ],
      ),
      body: PaperGrid(
        child: SafeArea(
          top: false,
          child: Obx(() {
            final complete = controller.savedPath.value != null;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
              children: [
                const Center(child: TechLabel('Mobile receiver')),
                const SizedBox(height: 14),
                Text(
                  complete ? 'File recovered.' : 'Point. Hold. Receive.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: QrFerryDesign.ink,
                    fontSize: 43,
                    height: 0.92,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -3.0,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  complete
                      ? 'The recovered file passed the end-to-end transfer checks.'
                      : 'Keep the full QR visible. Missed or duplicate frames are ignored safely.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: QrFerryDesign.muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 28),
                HardShadowBox(
                  color: QrFerryDesign.ink,
                  shadowOffset: 9,
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (!complete)
                              MobileScanner(
                                controller: controller.scannerController,
                                onDetect: controller.onDetect,
                              )
                            else
                              Container(color: const Color(0xFF27313B)),
                            const IgnorePointer(child: _ScannerReticle()),
                            if (complete)
                              Center(
                                child: Container(
                                  width: 92,
                                  height: 92,
                                  decoration: const BoxDecoration(
                                    color: QrFerryDesign.signal,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Color(0x22E7FF54), spreadRadius: 12)],
                                  ),
                                  child: const Icon(Icons.check_rounded, size: 48, color: QrFerryDesign.ink),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(22),
                        child: complete ? _CompletePanel(controller: controller) : _ReceivePanel(controller: controller),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ScannerReticle extends StatelessWidget {
  const _ScannerReticle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(34),
      child: CustomPaint(painter: _ReticlePainter()),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = QrFerryDesign.signal..strokeWidth = 3..style = PaintingStyle.stroke;
    const c = 58.0;
    final path = Path()
      ..moveTo(0, c)..lineTo(0, 0)..lineTo(c, 0)
      ..moveTo(size.width - c, 0)..lineTo(size.width, 0)..lineTo(size.width, c)
      ..moveTo(size.width, size.height - c)..lineTo(size.width, size.height)..lineTo(size.width - c, size.height)
      ..moveTo(c, size.height)..lineTo(0, size.height)..lineTo(0, size.height - c);
    canvas.drawPath(path, p);
    final line = Paint()..color = QrFerryDesign.signal.withValues(alpha: 0.75)..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReceivePanel extends StatelessWidget {
  const _ReceivePanel({required this.controller});
  final ReceiveController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progress.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(color: QrFerryDesign.signal, shape: BoxShape.circle),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                controller.hasSession.value ? 'Receiving QR frames' : 'Looking for QRFerry',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
            Text(Formatters.percent(progress), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 14),
        LinearProgressIndicator(
          value: progress,
          minHeight: 7,
          backgroundColor: const Color(0xFFE6E7E4),
          valueColor: const AlwaysStoppedAnimation(QrFerryDesign.blue),
        ),
        const SizedBox(height: 18),
        if (controller.hasSession.value)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: QrFerryDesign.line)),
            child: Row(
              children: [
                Container(width: 35, height: 40, color: QrFerryDesign.blue, child: const Icon(Icons.arrow_downward, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.filename.value ?? 'Incoming file',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.receivedCount.value} / ${controller.chunkCount.value} unique frames',
                        style: const TextStyle(color: QrFerryDesign.muted, fontFamily: 'monospace', fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          const Text(
            'Keep the complete QR inside the lime guide.',
            style: TextStyle(color: QrFerryDesign.muted, fontSize: 12, height: 1.45),
          ),
        if (controller.invalidFrames.value > 0) ...[
          const SizedBox(height: 12),
          Text(
            '${controller.invalidFrames.value} rejected / unreadable frame(s)',
            style: const TextStyle(color: QrFerryDesign.muted, fontFamily: 'monospace', fontSize: 9),
          ),
        ],
        if (controller.error.value != null) ...[
          const SizedBox(height: 12),
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
    );
  }
}

class _CompletePanel extends StatelessWidget {
  const _CompletePanel({required this.controller});
  final ReceiveController controller;

  @override
  Widget build(BuildContext context) {
    void share() {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
      controller.shareRecoveredFile(origin);
    }

    return Column(
      children: [
        const Text('Transfer verified', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
          controller.filename.value ?? 'File recovered',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: QrFerryDesign.muted, fontSize: 12),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: share,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Share / Save file'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: controller.reset, child: const Text('Scan another transfer')),
      ],
    );
  }
}
