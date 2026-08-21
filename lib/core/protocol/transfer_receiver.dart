import 'dart:io';
import 'dart:typed_data';

import 'crc32.dart';
import 'transfer_frame.dart';

enum FrameAcceptResult {
  accepted,
  duplicate,
  differentSession,
  invalidMetadata,
}

class RecoveredTransfer {
  const RecoveredTransfer({required this.filename, required this.bytes});

  final String filename;
  final Uint8List bytes;
}

class TransferCollector {
  int? _session;
  int? _chunkCount;
  int? _originalSize;
  int? _transmittedSize;
  int? _originalCrc;
  int? _transmittedCrc;
  bool? _compressed;
  String? _filename;

  final Map<int, Uint8List> _chunks = <int, Uint8List>{};

  int? get session => _session;
  String? get filename => _filename;

  int get receivedCount => _chunks.length;
  int get chunkCount => _chunkCount ?? 0;

  bool get hasSession => _session != null;

  bool get isComplete => _chunkCount != null && _chunks.length == _chunkCount;

  double get progress {
    final total = _chunkCount;
    if (total == null || total == 0) return 0;
    return (_chunks.length / total).clamp(0, 1);
  }

  FrameAcceptResult accept(TransferFrame frame) {
    if (_session == null) {
      _adoptMetadata(frame);
    } else if (_session != frame.session) {
      return FrameAcceptResult.differentSession;
    }

    if (!_metadataMatches(frame)) {
      return FrameAcceptResult.invalidMetadata;
    }

    if (_chunks.containsKey(frame.chunkIndex)) {
      return FrameAcceptResult.duplicate;
    }

    _chunks[frame.chunkIndex] = Uint8List.fromList(frame.payload);

    return FrameAcceptResult.accepted;
  }

  RecoveredTransfer recover() {
    if (!isComplete) {
      throw StateError('Transfer is not complete.');
    }

    final transmittedBuilder = BytesBuilder(copy: false);

    for (var index = 0; index < _chunkCount!; index++) {
      final chunk = _chunks[index];
      if (chunk == null) {
        throw StateError('Missing chunk $index.');
      }
      transmittedBuilder.add(chunk);
    }

    var transmitted = transmittedBuilder.takeBytes();

    if (transmitted.length < _transmittedSize!) {
      throw StateError('Recovered data is shorter than expected.');
    }

    if (transmitted.length > _transmittedSize!) {
      transmitted = Uint8List.sublistView(transmitted, 0, _transmittedSize!);
    }

    if (Crc32.ofUint8List(transmitted) != _transmittedCrc) {
      throw StateError('Transmitted payload CRC32 failed.');
    }

    final original = _compressed!
        ? Uint8List.fromList(gzip.decode(transmitted))
        : Uint8List.fromList(transmitted);

    if (original.length != _originalSize) {
      throw StateError('Recovered file size does not match.');
    }

    if (Crc32.ofUint8List(original) != _originalCrc) {
      throw StateError('Recovered file CRC32 failed.');
    }

    return RecoveredTransfer(
      filename: _safeFilename(_filename ?? 'transfer.bin'),
      bytes: original,
    );
  }

  void reset() {
    _session = null;
    _chunkCount = null;
    _originalSize = null;
    _transmittedSize = null;
    _originalCrc = null;
    _transmittedCrc = null;
    _compressed = null;
    _filename = null;
    _chunks.clear();
  }

  void _adoptMetadata(TransferFrame frame) {
    _session = frame.session;
    _chunkCount = frame.chunkCount;
    _originalSize = frame.originalSize;
    _transmittedSize = frame.transmittedSize;
    _originalCrc = frame.originalCrc;
    _transmittedCrc = frame.transmittedCrc;
    _compressed = frame.compressed;
    _filename = frame.filename;
  }

  bool _metadataMatches(TransferFrame frame) {
    return frame.session == _session &&
        frame.chunkCount == _chunkCount &&
        frame.originalSize == _originalSize &&
        frame.transmittedSize == _transmittedSize &&
        frame.originalCrc == _originalCrc &&
        frame.transmittedCrc == _transmittedCrc &&
        frame.compressed == _compressed &&
        frame.filename == _filename;
  }

  static String _safeFilename(String value) {
    var safe = value
        .replaceAll(RegExp(r'[/\\\x00]'), '_')
        .replaceAll('..', '_')
        .trim();

    if (safe.isEmpty || safe == '.' || safe == '_') {
      safe = 'transfer.bin';
    }

    return safe;
  }
}
