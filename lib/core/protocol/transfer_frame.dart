import 'dart:convert';
import 'dart:typed_data';

import 'crc32.dart';

class InvalidTransferFrame implements Exception {
  const InvalidTransferFrame(this.message);

  final String message;

  @override
  String toString() => 'InvalidTransferFrame: $message';
}

class TransferFrame {
  const TransferFrame({
    required this.session,
    required this.chunkIndex,
    required this.chunkCount,
    required this.originalSize,
    required this.transmittedSize,
    required this.originalCrc,
    required this.transmittedCrc,
    required this.compressed,
    required this.filename,
    required this.payload,
  });

  static const int protocolVersion = 1;
  static const int fixedHeaderBytes = 37;
  static const int frameCrcBytes = 4;
  static const int maxFilenameBytes = 80;

  static const List<int> _magic = [0x46, 0x51, 0x52, 0x31]; // FQR1

  final int session;
  final int chunkIndex;
  final int chunkCount;
  final int originalSize;
  final int transmittedSize;
  final int originalCrc;
  final int transmittedCrc;
  final bool compressed;
  final String filename;
  final Uint8List payload;

  double get progress => chunkCount <= 0 ? 0 : (chunkIndex + 1) / chunkCount;

  Uint8List serialize() {
    final filenameBytes = _filenameBytes(filename);
    final frameLength =
        fixedHeaderBytes +
        filenameBytes.length +
        payload.length +
        frameCrcBytes;

    final bytes = Uint8List(frameLength);
    final data = ByteData.sublistView(bytes);

    bytes.setRange(0, 4, _magic);
    bytes[4] = protocolVersion;
    bytes[5] = compressed ? 0x01 : 0x00;

    data.setUint32(6, session, Endian.little);
    data.setUint32(10, chunkIndex, Endian.little);
    data.setUint32(14, chunkCount, Endian.little);
    data.setUint32(18, originalSize, Endian.little);
    data.setUint32(22, transmittedSize, Endian.little);
    data.setUint32(26, originalCrc, Endian.little);
    data.setUint32(30, transmittedCrc, Endian.little);

    bytes[34] = filenameBytes.length;
    data.setUint16(35, payload.length, Endian.little);

    final filenameOffset = fixedHeaderBytes;
    final payloadOffset = filenameOffset + filenameBytes.length;
    final crcOffset = payloadOffset + payload.length;

    bytes.setRange(filenameOffset, payloadOffset, filenameBytes);
    bytes.setRange(payloadOffset, crcOffset, payload);

    final frameCrc = Crc32.ofBytes(bytes.sublist(0, crcOffset));
    data.setUint32(crcOffset, frameCrc, Endian.little);

    return bytes;
  }

  static TransferFrame parse(Uint8List bytes) {
    if (bytes.length < fixedHeaderBytes + frameCrcBytes) {
      throw const InvalidTransferFrame('Frame is too short.');
    }

    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) {
        throw const InvalidTransferFrame('Magic header does not match.');
      }
    }

    if (bytes[4] != protocolVersion) {
      throw InvalidTransferFrame('Unsupported protocol version ${bytes[4]}.');
    }

    final data = ByteData.sublistView(bytes);
    final filenameLength = bytes[34];
    final payloadLength = data.getUint16(35, Endian.little);

    final expectedLength =
        fixedHeaderBytes + filenameLength + payloadLength + frameCrcBytes;

    if (bytes.length != expectedLength) {
      throw const InvalidTransferFrame('Frame length does not match header.');
    }

    final crcOffset = expectedLength - frameCrcBytes;
    final expectedCrc = data.getUint32(crcOffset, Endian.little);
    final actualCrc = Crc32.ofBytes(bytes.sublist(0, crcOffset));

    if (expectedCrc != actualCrc) {
      throw const InvalidTransferFrame('Frame CRC32 failed.');
    }

    final chunkIndex = data.getUint32(10, Endian.little);
    final chunkCount = data.getUint32(14, Endian.little);

    if (chunkCount == 0 || chunkIndex >= chunkCount) {
      throw const InvalidTransferFrame('Invalid chunk index/count.');
    }

    final filenameOffset = fixedHeaderBytes;
    final payloadOffset = filenameOffset + filenameLength;

    final filename = utf8.decode(
      bytes.sublist(filenameOffset, payloadOffset),
      allowMalformed: true,
    );

    final payload = Uint8List.fromList(bytes.sublist(payloadOffset, crcOffset));

    return TransferFrame(
      session: data.getUint32(6, Endian.little),
      chunkIndex: chunkIndex,
      chunkCount: chunkCount,
      originalSize: data.getUint32(18, Endian.little),
      transmittedSize: data.getUint32(22, Endian.little),
      originalCrc: data.getUint32(26, Endian.little),
      transmittedCrc: data.getUint32(30, Endian.little),
      compressed: (bytes[5] & 0x01) != 0,
      filename: filename.isEmpty ? 'transfer.bin' : filename,
      payload: payload,
    );
  }

  static Uint8List _filenameBytes(String filename) {
    final encoded = Uint8List.fromList(utf8.encode(filename));
    if (encoded.length <= maxFilenameBytes) return encoded;

    final builder = BytesBuilder(copy: false);

    for (final rune in filename.runes) {
      final runeBytes = utf8.encode(String.fromCharCode(rune));
      if (builder.length + runeBytes.length > maxFilenameBytes) break;
      builder.add(runeBytes);
    }

    final result = builder.takeBytes();

    if (result.isEmpty) {
      return Uint8List.fromList(utf8.encode('transfer.bin'));
    }

    return result;
  }
}
