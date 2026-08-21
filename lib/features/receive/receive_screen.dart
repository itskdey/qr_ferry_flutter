import 'dart:convert';
import 'dart:io';

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
          IconButton(
            tooltip: 'Torch',
            onPressed: controller.toggleTorch,
            icon: const Icon(Icons.flash_on_outlined),
          ),
        ],
      ),
      body: PaperGrid(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            children: [
              const Center(child: TechLabel('Mobile receiver')),
              const SizedBox(height: 14),
              Obx(() {
                final complete = controller.savedPath.value != null;
                return Text(
                  complete ? 'Transfer verified.' : 'Point. Hold. Receive.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: QrFerryDesign.ink,
                    fontSize: 43,
                    height: 0.92,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -3,
                  ),
                );
              }),
              const SizedBox(height: 14),
              Obx(() {
                final complete = controller.savedPath.value != null;
                return Text(
                  complete
                      ? 'The file passed the transfer integrity checks. Preview it below, then save or share it.'
                      : 'Keep the full QR visible. The optical link will lock automatically when a valid QRFerry stream appears.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: QrFerryDesign.muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                );
              }),
              const SizedBox(height: 28),
              HardShadowBox(
                color: QrFerryDesign.ink,
                shadowOffset: 9,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Obx(() {
                        final complete = controller.savedPath.value != null;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            if (!complete)
                              MobileScanner(
                                controller: controller.scannerController,
                                onDetect: controller.onDetect,
                              )
                            else
                              Container(color: const Color(0xFF27313B)),
                            if (!complete)
                              Obx(
                                () => IgnorePointer(
                                  child: _ScannerReticle(
                                    active: controller.hasSession.value,
                                  ),
                                ),
                              ),
                            if (!complete)
                              Obx(
                                () => IgnorePointer(
                                  child: _CameraStatus(
                                    active: controller.hasSession.value,
                                    sessionId: controller.sessionId.value,
                                  ),
                                ),
                              ),
                            if (complete) const _VerifiedCameraState(),
                          ],
                        );
                      }),
                    ),
                    Obx(() {
                      final savedPath = controller.savedPath.value;
                      final complete = savedPath != null;

                      return Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(22),
                        child: complete
                            ? _CompletePanel(
                                filename: controller.filename.value,
                                savedPath: savedPath,
                                sessionId: controller.sessionId.value,
                                receivedCount: controller.receivedCount.value,
                                invalidFrames: controller.invalidFrames.value,
                                originalSize: controller.originalSize.value,
                                rateBytesPerSecond:
                                    controller.transferRateBytesPerSecond.value,
                                elapsedSeconds: controller.elapsedSeconds.value,
                                onShare: () => _shareRecoveredFile(context),
                                onReset: controller.reset,
                              )
                            : _ReceivePanel(
                                hasSession: controller.hasSession.value,
                                sessionId: controller.sessionId.value,
                                filename: controller.filename.value,
                                receivedCount: controller.receivedCount.value,
                                chunkCount: controller.chunkCount.value,
                                progress: controller.progress.value,
                                invalidFrames: controller.invalidFrames.value,
                                error: controller.error.value,
                                rateBytesPerSecond:
                                    controller.transferRateBytesPerSecond.value,
                                acceptedFps:
                                    controller.acceptedFramesPerSecond.value,
                                etaSeconds: controller.etaSeconds.value,
                              ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const _ProtocolStrip(),
            ],
          ),
        ),
      ),
    );
  }

  void _shareRecoveredFile(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    controller.shareRecoveredFile(origin);
  }
}

class _ScannerReticle extends StatefulWidget {
  const _ScannerReticle({required this.active});

  final bool active;

  @override
  State<_ScannerReticle> createState() => _ScannerReticleState();
}

class _ScannerReticleState extends State<_ScannerReticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    )..repeat(reverse: true);
  }

  Duration get _duration => Duration(milliseconds: widget.active ? 850 : 1900);

  @override
  void didUpdateWidget(covariant _ScannerReticle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _controller.duration = _duration;
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(34),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _ReticlePainter(
            progress: _controller.value,
            active: widget.active,
          ),
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter({required this.progress, required this.active});

  final double progress;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = QrFerryDesign.signal
      ..strokeWidth = active ? 3.5 : 2.5
      ..style = PaintingStyle.stroke;

    const corner = 58.0;
    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, 0)
      ..lineTo(corner, 0)
      ..moveTo(size.width - corner, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, corner)
      ..moveTo(size.width, size.height - corner)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - corner, size.height)
      ..moveTo(corner, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - corner);

    canvas.drawPath(path, border);

    final y = size.height * (0.13 + (0.74 * progress));
    final scanLine = Paint()
      ..color = QrFerryDesign.signal.withValues(alpha: active ? 0.95 : 0.62)
      ..strokeWidth = active ? 2 : 1;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), scanLine);

    if (active) {
      final glow = Paint()
        ..color = QrFerryDesign.signal.withValues(alpha: 0.13)
        ..strokeWidth = 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), glow);
    }
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.active != active;
  }
}

class _CameraStatus extends StatelessWidget {
  const _CameraStatus({required this.active, required this.sessionId});

  final bool active;
  final int? sessionId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: QrFerryDesign.ink.withValues(alpha: 0.88),
            border: Border.all(
              color: active ? QrFerryDesign.signal : const Color(0xFF5B6670),
            ),
          ),
          child: Text(
            active
                ? '● LINK LOCKED  ·  ${_sessionCode(sessionId)}'
                : 'WAITING FOR OPTICAL STREAM',
            style: TextStyle(
              color: active ? QrFerryDesign.signal : const Color(0xFFC2C8CD),
              fontFamily: 'monospace',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.65,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifiedCameraState extends StatelessWidget {
  const _VerifiedCameraState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: QrFerryDesign.signal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x22E7FF54), spreadRadius: 12),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 48,
              color: QrFerryDesign.ink,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'CRC32 VERIFIED',
            style: TextStyle(
              color: QrFerryDesign.signal,
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivePanel extends StatelessWidget {
  const _ReceivePanel({
    required this.hasSession,
    required this.sessionId,
    required this.filename,
    required this.receivedCount,
    required this.chunkCount,
    required this.progress,
    required this.invalidFrames,
    required this.error,
    required this.rateBytesPerSecond,
    required this.acceptedFps,
    required this.etaSeconds,
  });

  final bool hasSession;
  final int? sessionId;
  final String? filename;
  final int receivedCount;
  final int chunkCount;
  final double progress;
  final int invalidFrames;
  final String? error;
  final double rateBytesPerSecond;
  final double acceptedFps;
  final int? etaSeconds;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: hasSession ? QrFerryDesign.signal : QrFerryDesign.muted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                hasSession ? 'Receiving optical stream' : 'Looking for QRFerry',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
            Text(
              Formatters.percent(progress),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
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
        if (hasSession)
          _TelemetryPanel(
            sessionId: sessionId,
            filename: filename,
            receivedCount: receivedCount,
            chunkCount: chunkCount,
            invalidFrames: invalidFrames,
            rateBytesPerSecond: rateBytesPerSecond,
            acceptedFps: acceptedFps,
            etaSeconds: etaSeconds,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFBF8),
              border: Border.all(color: QrFerryDesign.line),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TechLabel('Optical link idle'),
                SizedBox(height: 7),
                Text(
                  'Keep the complete QR inside the lime guide. Telemetry appears as soon as the first valid frame is accepted.',
                  style: TextStyle(
                    color: QrFerryDesign.muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0EB),
              border: Border(
                left: BorderSide(color: QrFerryDesign.red, width: 3),
              ),
            ),
            child: Text(
              error!,
              style: const TextStyle(color: Color(0xFF842F21), fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}

class _TelemetryPanel extends StatelessWidget {
  const _TelemetryPanel({
    required this.sessionId,
    required this.filename,
    required this.receivedCount,
    required this.chunkCount,
    required this.invalidFrames,
    required this.rateBytesPerSecond,
    required this.acceptedFps,
    required this.etaSeconds,
  });

  final int? sessionId;
  final String? filename;
  final int receivedCount;
  final int chunkCount;
  final int invalidFrames;
  final double rateBytesPerSecond;
  final double acceptedFps;
  final int? etaSeconds;

  @override
  Widget build(BuildContext context) {
    final quality = _linkQuality(acceptedFps, invalidFrames, receivedCount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: QrFerryDesign.darkInset,
        border: Border.all(color: QrFerryDesign.ink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  filename ?? 'Incoming file',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                quality,
                style: TextStyle(
                  color: quality == 'GOOD'
                      ? QrFerryDesign.signal
                      : const Color(0xFFFFC963),
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(color: Color(0xFF35404C), height: 1),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(child: _Metric('SESSION', _sessionCode(sessionId))),
              Expanded(child: _Metric('FRAMES', '$receivedCount / $chunkCount')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  'RATE',
                  rateBytesPerSecond <= 0
                      ? 'CALCULATING'
                      : '${Formatters.bytes(rateBytesPerSecond.round())}/s',
                ),
              ),
              Expanded(child: _Metric('ETA', _eta(etaSeconds))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  'OPTICAL FPS',
                  acceptedFps <= 0 ? '—' : acceptedFps.toStringAsFixed(1),
                ),
              ),
              Expanded(child: _Metric('REJECTED', '$invalidFrames')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7E8993),
            fontFamily: 'monospace',
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CompletePanel extends StatelessWidget {
  const _CompletePanel({
    required this.filename,
    required this.savedPath,
    required this.sessionId,
    required this.receivedCount,
    required this.invalidFrames,
    required this.originalSize,
    required this.rateBytesPerSecond,
    required this.elapsedSeconds,
    required this.onShare,
    required this.onReset,
  });

  final String? filename;
  final String savedPath;
  final int? sessionId;
  final int receivedCount;
  final int invalidFrames;
  final int originalSize;
  final double rateBytesPerSecond;
  final double elapsedSeconds;
  final VoidCallback onShare;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TechLabel('End-to-end verification', color: QrFerryDesign.ink),
        const SizedBox(height: 7),
        const Text(
          'TRANSFER VERIFIED',
          style: TextStyle(
            color: QrFerryDesign.ink,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          filename ?? 'File recovered',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: QrFerryDesign.muted, fontSize: 12),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: QrFerryDesign.darkInset,
            border: Border.all(color: QrFerryDesign.ink),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _Metric('SESSION', _sessionCode(sessionId))),
                  const Expanded(child: _Metric('CRC32', 'PASSED')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Metric('FRAMES', '$receivedCount')),
                  Expanded(child: _Metric('REJECTED', '$invalidFrames')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      'SIZE',
                      originalSize <= 0 ? '—' : Formatters.bytes(originalSize),
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      'TIME',
                      _elapsed(elapsedSeconds),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      'AVG RATE',
                      rateBytesPerSecond <= 0
                          ? '—'
                          : '${Formatters.bytes(rateBytesPerSecond.round())}/s',
                    ),
                  ),
                  const Expanded(child: _Metric('STATUS', 'LOCAL ONLY')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const TechLabel('Preview'),
        const SizedBox(height: 9),
        _ReceivedFilePreview(path: savedPath, filename: filename),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.ios_share_rounded),
          label: const Text('Share / Save file'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onReset,
          child: const Text('Scan another transfer'),
        ),
      ],
    );
  }
}

class _ReceivedFilePreview extends StatelessWidget {
  const _ReceivedFilePreview({required this.path, required this.filename});

  final String path;
  final String? filename;

  static const _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  };

  static const _textExtensions = {
    'txt',
    'md',
    'json',
    'csv',
    'log',
    'xml',
    'yaml',
    'yml',
    'dart',
    'js',
    'ts',
    'tsx',
    'jsx',
    'html',
    'css',
    'scss',
    'py',
    'java',
    'kt',
    'swift',
    'c',
    'h',
    'cpp',
    'hpp',
    'rs',
    'go',
    'sql',
    'sh',
  };

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    final name = filename ?? file.uri.pathSegments.last;
    final extension = _extension(name);

    if (_imageExtensions.contains(extension)) {
      return _imagePreview(context, file, name);
    }
    if (_textExtensions.contains(extension)) {
      return _textPreview(file, name);
    }
    return _genericPreview(file, name, extension);
  }

  Widget _imagePreview(BuildContext context, File file, String name) {
    return FutureBuilder<int>(
      future: file.length(),
      builder: (context, sizeSnapshot) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _showImageFullscreen(context, file, name),
            child: Container(
              constraints: const BoxConstraints(minHeight: 180, maxHeight: 380),
              decoration: BoxDecoration(
                color: QrFerryDesign.darkInset,
                border: Border.all(color: QrFerryDesign.ink),
              ),
              child: Image.file(
                file,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const _PreviewError(
                  message: 'The image could not be decoded.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _PreviewMeta(
            name: name,
            size: sizeSnapshot.data,
            hint: 'Tap image for fullscreen preview',
          ),
        ],
      ),
    );
  }

  Widget _textPreview(File file, String name) {
    return FutureBuilder<_TextPreviewData>(
      future: _readTextPreview(file),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _PreviewLoading();
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const _PreviewError(
            message: 'This text file could not be previewed.',
          );
        }

        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 280,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: QrFerryDesign.darkInset,
                border: Border.all(color: QrFerryDesign.ink),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  data.text,
                  style: const TextStyle(
                    color: Color(0xFFE5E9EC),
                    fontFamily: 'monospace',
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _PreviewMeta(
              name: name,
              size: data.fileSize,
              hint: data.truncated
                  ? 'Preview limited to first 6,000 characters'
                  : 'Text preview',
            ),
          ],
        );
      },
    );
  }

  Widget _genericPreview(File file, String name, String extension) {
    return FutureBuilder<int>(
      future: file.length(),
      builder: (context, snapshot) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFBF8),
          border: Border.all(color: QrFerryDesign.line),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 62,
              color: QrFerryDesign.ink,
              child: Icon(
                _iconForExtension(extension),
                color: QrFerryDesign.signal,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: QrFerryDesign.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${snapshot.data == null ? '—' : Formatters.bytes(snapshot.data!)} · ${_labelForExtension(extension)}',
                    style: const TextStyle(
                      color: QrFerryDesign.muted,
                      fontFamily: 'monospace',
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Inline content preview is not available for this file type yet.',
                    style: TextStyle(
                      color: QrFerryDesign.muted,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<_TextPreviewData> _readTextPreview(File file) async {
    const maxReadBytes = 128 * 1024;
    const maxChars = 6000;
    final size = await file.length();
    final raf = await file.open();
    try {
      final bytes = await raf.read(size > maxReadBytes ? maxReadBytes : size);
      var text = utf8.decode(bytes, allowMalformed: true);
      final truncated = size > maxReadBytes || text.length > maxChars;
      if (text.length > maxChars) text = text.substring(0, maxChars);
      return _TextPreviewData(
        text: text,
        fileSize: size,
        truncated: truncated,
      );
    } finally {
      await raf.close();
    }
  }

  void _showImageFullscreen(BuildContext context, File file, String name) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xF2111820),
      builder: (context) => Dialog.fullscreen(
        backgroundColor: QrFerryDesign.ink,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(child: Image.file(file, fit: BoxFit.contain)),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: QrFerryDesign.ink,
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
    );
  }

  String _extension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  IconData _iconForExtension(String extension) {
    if (extension == 'pdf') return Icons.picture_as_pdf_outlined;
    if ({'mp4', 'mov', 'mkv', 'avi', 'webm'}.contains(extension)) {
      return Icons.movie_outlined;
    }
    if ({'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'}.contains(extension)) {
      return Icons.audio_file_outlined;
    }
    if ({'zip', 'rar', '7z', 'tar', 'gz'}.contains(extension)) {
      return Icons.folder_zip_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _labelForExtension(String extension) {
    if (extension.isEmpty) return 'FILE';
    if (extension == 'pdf') return 'PDF DOCUMENT';
    if ({'mp4', 'mov', 'mkv', 'avi', 'webm'}.contains(extension)) return 'VIDEO';
    if ({'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'}.contains(extension)) {
      return 'AUDIO';
    }
    if ({'zip', 'rar', '7z', 'tar', 'gz'}.contains(extension)) return 'ARCHIVE';
    return '${extension.toUpperCase()} FILE';
  }
}

class _PreviewMeta extends StatelessWidget {
  const _PreviewMeta({required this.name, required this.size, required this.hint});

  final String name;
  final int? size;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: QrFerryDesign.ink,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            size == null ? hint : '${Formatters.bytes(size!)} · $hint',
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: QrFerryDesign.muted,
              fontFamily: 'monospace',
              fontSize: 8,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewLoading extends StatelessWidget {
  const _PreviewLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: QrFerryDesign.darkInset,
        border: Border.all(color: QrFerryDesign.ink),
      ),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: QrFerryDesign.signal,
        ),
      ),
    );
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              color: QrFerryDesign.signal,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB3BBC2),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _TextPreviewData {
  const _TextPreviewData({
    required this.text,
    required this.fileSize,
    required this.truncated,
  });

  final String text;
  final int fileSize;
  final bool truncated;
}

String _sessionCode(int? sessionId) {
  if (sessionId == null) return '--------';
  final hex = sessionId.toUnsigned(32).toRadixString(16).padLeft(8, '0').toUpperCase();
  return '${hex.substring(0, 4)}-${hex.substring(4)}';
}

String _eta(int? seconds) {
  if (seconds == null) return 'CALCULATING';
  if (seconds <= 0) return '00:00';
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
}

String _elapsed(double seconds) {
  if (seconds <= 0) return '00:00';
  return _eta(seconds.round());
}

String _linkQuality(double fps, int rejected, int received) {
  if (received < 3) return 'LOCKING';
  if (rejected > received) return 'UNSTABLE';
  if (fps >= 4) return 'GOOD';
  if (fps >= 1.5) return 'DEGRADED';
  return 'LOCKING';
}
