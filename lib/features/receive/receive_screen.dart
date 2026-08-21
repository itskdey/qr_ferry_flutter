import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/protocol/transfer_frame.dart';
import '../../core/protocol/transfer_receiver.dart';
import '../../core/utils/formatters.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  late final MobileScannerController _scannerController;
  final TransferCollector _collector = TransferCollector();

  bool _handlingCapture = false;
  bool _finished = false;
  String? _savedPath;
  String? _error;
  int _invalidFrames = 0;

  @override
  void initState() {
    super.initState();

    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.unrestricted,
      formats: const [BarcodeFormat.qrCode],
      returnImage: false,
      autoZoom: true,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handlingCapture || _finished) return;

    _handlingCapture = true;

    try {
      for (final barcode in capture.barcodes) {
        final bytes = _decodedBytes(barcode);
        if (bytes == null || bytes.isEmpty) continue;

        TransferFrame frame;

        try {
          frame = TransferFrame.parse(bytes);
        } on InvalidTransferFrame {
          _invalidFrames++;
          continue;
        } catch (_) {
          _invalidFrames++;
          continue;
        }

        final result = _collector.accept(frame);

        if (result == FrameAcceptResult.invalidMetadata) {
          _error = 'A frame had inconsistent transfer metadata.';
          continue;
        }

        if (mounted) {
          setState(() {});
        }

        if (_collector.isComplete) {
          await _completeTransfer();
          break;
        }
      }
    } finally {
      _handlingCapture = false;
    }
  }

  Uint8List? _decodedBytes(Barcode barcode) {
    final decoded = barcode.rawDecodedBytes;

    if (decoded is DecodedBarcodeBytes) {
      return decoded.bytes;
    }

    if (decoded is DecodedVisionBarcodeBytes) {
      return decoded.bytes;
    }

    // Legacy fallback. For QR byte mode, rawDecodedBytes is preferred.
    return barcode.rawBytes;
  }

  Future<void> _completeTransfer() async {
    if (_finished) return;

    _finished = true;
    await _scannerController.stop();

    try {
      final recovered = _collector.recover();
      final documents = await getApplicationDocumentsDirectory();
      final receivedDirectory = Directory(
        '${documents.path}${Platform.pathSeparator}QR_Ferry_Received',
      );

      if (!await receivedDirectory.exists()) {
        await receivedDirectory.create(recursive: true);
      }

      final file = await _uniqueFile(
        receivedDirectory,
        recovered.filename,
      );

      await file.writeAsBytes(
        recovered.bytes,
        flush: true,
      );

      if (!mounted) return;

      setState(() {
        _savedPath = file.path;
        _error = null;
      });
    } catch (error) {
      _finished = false;

      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });

      await _scannerController.start();
    }
  }

  Future<File> _uniqueFile(Directory directory, String filename) async {
    final dot = filename.lastIndexOf('.');
    final hasExtension = dot > 0 && dot < filename.length - 1;
    final base = hasExtension ? filename.substring(0, dot) : filename;
    final extension = hasExtension ? filename.substring(dot) : '';

    var candidate = File(
      '${directory.path}${Platform.pathSeparator}$filename',
    );

    var index = 1;

    while (await candidate.exists()) {
      candidate = File(
        '${directory.path}${Platform.pathSeparator}$base ($index)$extension',
      );
      index++;
    }

    return candidate;
  }

  Future<void> _shareRecoveredFile() async {
    final path = _savedPath;
    if (path == null) return;

    final box = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: 'Received with QR Ferry',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> _reset() async {
    _collector.reset();
    _finished = false;
    _savedPath = null;
    _error = null;
    _invalidFrames = 0;

    setState(() {});

    await _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    final savedPath = _savedPath;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Receive',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Torch',
            onPressed: _scannerController.toggleTorch,
            icon: const Icon(Icons.flash_on_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (savedPath == null)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
          if (savedPath == null)
            const IgnorePointer(
              child: _ScannerGuide(),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.all(16),
              child: _BottomPanel(
                collector: _collector,
                invalidFrames: _invalidFrames,
                error: _error,
                savedPath: savedPath,
                onShare: _shareRecoveredFile,
                onReset: _reset,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerGuide extends StatelessWidget {
  const _ScannerGuide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.78,
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: _GuidePainter(),
          ),
        ),
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(28)),
      dimPaint,
    );

    const corner = 42.0;

    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, 12)
      ..quadraticBezierTo(0, 0, 12, 0)
      ..lineTo(corner, 0)
      ..moveTo(size.width - corner, 0)
      ..lineTo(size.width - 12, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 12)
      ..lineTo(size.width, corner)
      ..moveTo(size.width, size.height - corner)
      ..lineTo(size.width, size.height - 12)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - 12,
        size.height,
      )
      ..lineTo(size.width - corner, size.height)
      ..moveTo(corner, size.height)
      ..lineTo(12, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 12)
      ..lineTo(0, size.height - corner);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.collector,
    required this.invalidFrames,
    required this.error,
    required this.savedPath,
    required this.onShare,
    required this.onReset,
  });

  final TransferCollector collector;
  final int invalidFrames;
  final String? error;
  final String? savedPath;
  final VoidCallback onShare;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final complete = savedPath != null;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xEE15171C),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: complete
          ? _buildComplete(context)
          : _buildScanning(context),
    );
  }

  Widget _buildScanning(BuildContext context) {
    final hasSession = collector.hasSession;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                hasSession
                    ? Icons.downloading_rounded
                    : Icons.center_focus_strong_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSession
                        ? collector.filename ?? 'Receiving file'
                        : 'Point at the sender',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasSession
                        ? '${collector.receivedCount} / ${collector.chunkCount} unique frames'
                        : 'Keep the complete QR inside the guide',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.52),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              Formatters.percent(collector.progress),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LinearProgressIndicator(
          value: collector.progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(999),
        ),
        if (invalidFrames > 0) ...[
          const SizedBox(height: 9),
          Text(
            '$invalidFrames unreadable/non-transfer QR frame(s) ignored',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 11,
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 10),
          Text(
            error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildComplete(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.greenAccent,
            size: 30,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Transfer complete',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          collector.filename ?? 'File recovered',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Receive another'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: onShare,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 50),
                ),
                child: const Text(
                  'Share / Save',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
