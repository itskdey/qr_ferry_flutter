import 'dart:typed_data';

abstract final class Crc32 {
  static final List<int> _table = List<int>.generate(256, (index) {
    var crc = index;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) == 1
          ? 0xEDB88320 ^ (crc >>> 1)
          : crc >>> 1;
    }
    return crc & 0xFFFFFFFF;
  }, growable: false);

  static int ofBytes(List<int> bytes) {
    var crc = 0xFFFFFFFF;

    for (final byte in bytes) {
      final tableIndex = (crc ^ byte) & 0xFF;
      crc = _table[tableIndex] ^ (crc >>> 8);
    }

    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }

  static int ofUint8List(Uint8List bytes) => ofBytes(bytes);
}
