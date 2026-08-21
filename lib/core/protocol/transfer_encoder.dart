import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'crc32.dart';
import 'transfer_frame.dart';

class PreparedTransfer {
  PreparedTransfer({
    required this.filename,
    required this.originalSize,
    required this.transmittedSize,
    required this.originalCrc,
    required this.transmittedCrc,
    required this.compressed,
    required this.session,
    required this.chunkSize,
    required Uint8List transmittedBytes,
  }) : _transmittedBytes = transmittedBytes;

  final String filename;
  final int originalSize;
  final int transmittedSize;
  final int originalCrc;
  final int transmittedCrc;
  final bool compressed;
  final int session;
  final int chunkSize;
  final Uint8List _transmittedBytes;

  int get chunkCount => math.max(1, (transmittedSize / chunkSize).ceil());

  Uint8List frameAt(int index) {
    if (index < 0 || index >= chunkCount) {
      throw RangeError.index(index, this, 'index', null, chunkCount);
    }

    final start = index * chunkSize;
    final end = math.min(start + chunkSize, transmittedSize);

    final payload = start >= transmittedSize
        ? Uint8List(0)
        : Uint8List.sublistView(_transmittedBytes, start, end);

    return TransferFrame(
      session: session,
      chunkIndex: index,
      chunkCount: chunkCount,
      originalSize: originalSize,
      transmittedSize: transmittedSize,
      originalCrc: originalCrc,
      transmittedCrc: transmittedCrc,
      compressed: compressed,
      filename: filename,
      payload: payload,
    ).serialize();
  }
}

abstract final class TransferEncoder {
  static const int defaultChunkSize = 512;
  static const int maxFileBytes = 20 * 1024 * 1024;

  static Future<PreparedTransfer> prepareFile(
    File file, {
    int chunkSize = defaultChunkSize,
  }) async {
    final original = await file.readAsBytes();

    return prepareBytes(
      filename: file.uri.pathSegments.isEmpty
          ? 'transfer.bin'
          : file.uri.pathSegments.last,
      original: original,
      chunkSize: chunkSize,
    );
  }

  static Future<PreparedTransfer> prepareBytes({
    required String filename,
    required Uint8List original,
    int chunkSize = defaultChunkSize,
  }) async {
    if (original.length > maxFileBytes) {
      throw ArgumentError('MVP limit is ${maxFileBytes ~/ (1024 * 1024)} MB.');
    }

    if (chunkSize < 128 || chunkSize > 1200) {
      throw ArgumentError('chunkSize must be between 128 and 1200 bytes.');
    }

    final originalCrc = Crc32.ofUint8List(original);

    final compressedList = await Isolate.run<List<int>>(
      () => gzip.encode(original),
    );
    final compressedBytes = Uint8List.fromList(compressedList);

    // Avoid compression unless it saves at least 5% and 32 bytes.
    final savesEnough =
        compressedBytes.length + 32 < original.length &&
        compressedBytes.length <= (original.length * 0.95).floor();

    final transmitted = savesEnough ? compressedBytes : original;
    final transmittedCrc = Crc32.ofUint8List(transmitted);

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final session =
        ((timestamp & 0xFFFFFFFF) ^ originalCrc ^ transmittedCrc) & 0xFFFFFFFF;

    return PreparedTransfer(
      filename: _safeDisplayFilename(filename),
      originalSize: original.length,
      transmittedSize: transmitted.length,
      originalCrc: originalCrc,
      transmittedCrc: transmittedCrc,
      compressed: savesEnough,
      session: session,
      chunkSize: chunkSize,
      transmittedBytes: Uint8List.fromList(transmitted),
    );
  }

  static String _safeDisplayFilename(String value) {
    final trimmed = value.trim();
    var safe = trimmed.isEmpty
        ? 'transfer.bin'
        : trimmed.replaceAll(RegExp(r'[/\\\x00]'), '_');

    if (utf8.encode(safe).length <= TransferFrame.maxFilenameBytes) {
      return safe;
    }

    final dot = safe.lastIndexOf('.');
    final extension = dot > 0 && dot < safe.length - 1
        ? safe.substring(dot)
        : '';
    final base = extension.isEmpty ? safe : safe.substring(0, dot);

    final extensionBytes = utf8.encode(extension);
    final available = (TransferFrame.maxFilenameBytes - extensionBytes.length)
        .clamp(8, 80);

    final builder = StringBuffer();
    var used = 0;

    for (final rune in base.runes) {
      final character = String.fromCharCode(rune);
      final length = utf8.encode(character).length;
      if (used + length > available) break;
      builder.write(character);
      used += length;
    }

    final shortened = '${builder.toString()}$extension';
    safe = shortened.isEmpty ? 'transfer.bin' : shortened;
    return safe;
  }
}
