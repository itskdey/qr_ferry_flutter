import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/protocol/transfer_frame.dart';
import '../../core/protocol/transfer_receiver.dart';

class ReceiveController extends GetxController {
  final scannerController = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.unrestricted,
    formats: const [BarcodeFormat.qrCode],
    returnImage: false,
    autoZoom: true,
  );

  final hasSession = false.obs;
  final sessionId = RxnInt();
  final filename = Rxn<String>();
  final receivedCount = 0.obs;
  final chunkCount = 0.obs;
  final progress = 0.0.obs;
  final invalidFrames = 0.obs;
  final savedPath = Rxn<String>();
  final error = Rxn<String>();

  final originalSize = 0.obs;
  final transmittedSize = 0.obs;
  final receivedPayloadBytes = 0.obs;
  final transferRateBytesPerSecond = 0.0.obs;
  final acceptedFramesPerSecond = 0.0.obs;
  final etaSeconds = RxnInt();
  final elapsedSeconds = 0.0.obs;

  final TransferCollector _collector = TransferCollector();
  bool _handlingCapture = false;
  bool _finished = false;
  bool _disposed = false;
  DateTime? _sessionStartedAt;

  Future<void> onDetect(BarcodeCapture capture) async {
    if (_handlingCapture || _finished || _disposed) return;

    _handlingCapture = true;

    try {
      for (final barcode in capture.barcodes) {
        final bytes = _decodedBytes(barcode);
        if (bytes == null || bytes.isEmpty) continue;

        TransferFrame frame;

        try {
          frame = TransferFrame.parse(bytes);
        } on InvalidTransferFrame {
          invalidFrames.value++;
          continue;
        } catch (_) {
          invalidFrames.value++;
          continue;
        }

        final result = _collector.accept(frame);

        if (result == FrameAcceptResult.invalidMetadata) {
          error.value = 'A frame had inconsistent transfer metadata.';
          continue;
        }

        if (result == FrameAcceptResult.accepted) {
          final firstFrame = _sessionStartedAt == null;
          _sessionStartedAt ??= DateTime.now();

          sessionId.value = frame.session;
          originalSize.value = frame.originalSize;
          transmittedSize.value = frame.transmittedSize;
          receivedPayloadBytes.value += frame.payload.length;

          _syncCollectorState();
          _updateTelemetry();

          if (firstFrame) {
            await HapticFeedback.selectionClick();
          }
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

  Future<void> toggleTorch() => scannerController.toggleTorch();

  Future<void> shareRecoveredFile(Rect? sharePositionOrigin) async {
    final path = savedPath.value;
    if (path == null) return;

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: 'Received with QR Ferry',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<void> reset() async {
    _collector.reset();
    _finished = false;
    _sessionStartedAt = null;

    savedPath.value = null;
    error.value = null;
    invalidFrames.value = 0;
    sessionId.value = null;
    originalSize.value = 0;
    transmittedSize.value = 0;
    receivedPayloadBytes.value = 0;
    transferRateBytesPerSecond.value = 0;
    acceptedFramesPerSecond.value = 0;
    etaSeconds.value = null;
    elapsedSeconds.value = 0;

    _syncCollectorState();

    if (!_disposed) await scannerController.start();
  }

  Uint8List? _decodedBytes(Barcode barcode) {
    final decoded = barcode.rawDecodedBytes;

    if (decoded is DecodedBarcodeBytes) return decoded.bytes;
    if (decoded is DecodedVisionBarcodeBytes) return decoded.bytes;

    return null;
  }

  Future<void> _completeTransfer() async {
    if (_finished || _disposed) return;

    _finished = true;
    _updateTelemetry();
    etaSeconds.value = 0;
    await scannerController.stop();

    try {
      final recovered = _collector.recover();
      final documents = await getApplicationDocumentsDirectory();
      final receivedDirectory = Directory(
        '${documents.path}${Platform.pathSeparator}QR_Ferry_Received',
      );

      if (!await receivedDirectory.exists()) {
        await receivedDirectory.create(recursive: true);
      }

      final file = await _uniqueFile(receivedDirectory, recovered.filename);
      await file.writeAsBytes(recovered.bytes, flush: true);

      if (_disposed) return;

      savedPath.value = file.path;
      error.value = null;
      await HapticFeedback.heavyImpact();
    } catch (caughtError) {
      _finished = false;
      if (_disposed) return;

      error.value = caughtError.toString();
      await scannerController.start();
    }
  }

  Future<File> _uniqueFile(Directory directory, String name) async {
    final dot = name.lastIndexOf('.');
    final hasExtension = dot > 0 && dot < name.length - 1;
    final base = hasExtension ? name.substring(0, dot) : name;
    final extension = hasExtension ? name.substring(dot) : '';

    var candidate = File('${directory.path}${Platform.pathSeparator}$name');
    var index = 1;

    while (await candidate.exists()) {
      candidate = File(
        '${directory.path}${Platform.pathSeparator}$base ($index)$extension',
      );
      index++;
    }

    return candidate;
  }

  void _syncCollectorState() {
    hasSession.value = _collector.hasSession;
    filename.value = _collector.filename;
    receivedCount.value = _collector.receivedCount;
    chunkCount.value = _collector.chunkCount;
    progress.value = _collector.progress;
  }

  void _updateTelemetry() {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) return;

    final elapsed = DateTime.now().difference(startedAt).inMilliseconds / 1000;
    elapsedSeconds.value = elapsed;

    if (elapsed < 0.25) {
      transferRateBytesPerSecond.value = 0;
      acceptedFramesPerSecond.value = 0;
      etaSeconds.value = null;
      return;
    }

    final bytesPerSecond = receivedPayloadBytes.value / elapsed;
    transferRateBytesPerSecond.value = bytesPerSecond;
    acceptedFramesPerSecond.value = receivedCount.value / elapsed;

    final remaining = transmittedSize.value - receivedPayloadBytes.value;
    etaSeconds.value = bytesPerSecond > 1 && remaining > 0
        ? (remaining / bytesPerSecond).ceil()
        : 0;
  }

  @override
  void onClose() {
    _disposed = true;
    scannerController.dispose();
    super.onClose();
  }
}
