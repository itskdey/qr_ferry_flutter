import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_ferry_flutter/core/protocol/crc32.dart';
import 'package:qr_ferry_flutter/core/protocol/transfer_encoder.dart';
import 'package:qr_ferry_flutter/core/protocol/transfer_frame.dart';
import 'package:qr_ferry_flutter/core/protocol/transfer_receiver.dart';

void main() {
  test('CRC32 matches the standard test vector', () {
    final bytes = Uint8List.fromList('123456789'.codeUnits);
    expect(Crc32.ofUint8List(bytes), 0xCBF43926);
  });

  test('TransferFrame binary round trip', () {
    final frame = TransferFrame(
      session: 123,
      chunkIndex: 2,
      chunkCount: 8,
      originalSize: 1024,
      transmittedSize: 900,
      originalCrc: 111,
      transmittedCrc: 222,
      compressed: true,
      filename: 'សាកល្បង.txt',
      payload: Uint8List.fromList([1, 2, 3, 4, 200, 201]),
    );

    final parsed = TransferFrame.parse(frame.serialize());

    expect(parsed.session, frame.session);
    expect(parsed.chunkIndex, frame.chunkIndex);
    expect(parsed.chunkCount, frame.chunkCount);
    expect(parsed.compressed, isTrue);
    expect(parsed.filename, frame.filename);
    expect(parsed.payload, frame.payload);
  });

  test('Complete transfer can be reconstructed out of order', () async {
    final original = Uint8List.fromList(
      List<int>.generate(5000, (index) => index % 251),
    );

    final prepared = await TransferEncoder.prepareBytes(
      filename: 'demo.bin',
      original: original,
      chunkSize: 333,
    );

    final frames = List<TransferFrame>.generate(
      prepared.chunkCount,
      (index) => TransferFrame.parse(prepared.frameAt(index)),
    ).reversed;

    final collector = TransferCollector();

    for (final frame in frames) {
      collector.accept(frame);
    }

    expect(collector.isComplete, isTrue);

    final recovered = collector.recover();

    expect(recovered.filename, 'demo.bin');
    expect(recovered.bytes, original);
  });
}
