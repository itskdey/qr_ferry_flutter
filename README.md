# QR Ferry Flutter

A Flutter MVP for **offline file transfer using animated QR codes**.

It is inspired by the transport idea in `deedy/qr-data-transfer`, but this project is a clean Flutter implementation with its own simple protocol.

## What works

- Pick any file on the sender
- Optional gzip compression when it reduces the payload
- Split the transmitted bytes into QR-sized chunks
- Binary QR byte mode (no Base64 expansion)
- Animated QR playback at 5 / 8 / 12 FPS
- Receiver scans continuously with `mobile_scanner`
- Frames may arrive out of order
- Duplicate frames are ignored
- Per-frame CRC32 validation
- Whole transmitted-payload CRC32 validation
- Whole original-file CRC32 validation
- Automatic decompression
- Save recovered file to app documents
- Share / Save recovered file through the system share sheet
- Android + iOS project files included

## Important difference from QRFerry

This is an MVP and **does not yet use RaptorQ fountain coding**.

If the receiver misses frame 17, it waits until the sender loops and frame 17 appears again. This keeps the implementation pure Dart and easy to understand.

The architecture is deliberately split so a Rust/RaptorQ codec can later replace the chunk collector without rewriting the UI.

## Run

```bash
flutter pub get
flutter run
```

Use two physical devices for the best test:

1. Device A → **Send**
2. Pick a file
3. Start the QR stream
4. Device B → **Receive**
5. Keep the full QR inside the scanner guide
6. When progress reaches 100%, tap **Share / Save**

## Performance

The default payload chunk is 512 bytes.

At 12 FPS the theoretical payload rate is roughly:

```text
512 × 12 = 6,144 bytes/sec
```

Actual speed is lower because cameras may skip frames and QR decoding has overhead.

For larger files, the next step is:

- RaptorQ / fountain coding
- native ZXing-C++ scanning
- native/Rust QR rendering
- dual-lane 30 + 30 FPS playback

## Protocol

Every QR frame contains:

```text
magic              4 bytes   "FQR1"
version            1 byte
flags              1 byte    bit 0 = gzip
session            4 bytes
chunk index        4 bytes
chunk count        4 bytes
original size      4 bytes
transmitted size   4 bytes
original CRC32     4 bytes
transmitted CRC32  4 bytes
filename length    1 byte
payload length     2 bytes
filename           N bytes
payload            N bytes
frame CRC32        4 bytes
```

All integer values use little-endian byte order.

## Project structure

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── protocol/
│   │   ├── crc32.dart
│   │   ├── transfer_encoder.dart
│   │   ├── transfer_frame.dart
│   │   └── transfer_receiver.dart
│   └── utils/
│       └── formatters.dart
├── features/
│   ├── home/home_screen.dart
│   ├── receive/receive_screen.dart
│   └── send/send_screen.dart
└── widgets/
    ├── binary_qr_view.dart
    └── ferry_card.dart
```

## iOS

The camera usage description is already included in `Info.plist`.

Minimum iOS target: **13.0**

## Android

The camera permission is already included in `AndroidManifest.xml`.

Minimum Android SDK: **24**

## Security / privacy

No server is used by this app. File bytes are shown optically as QR codes and reconstructed locally on the receiving device.

Anyone who can see and scan the QR stream can receive the file, so do not treat the stream as encrypted.

## Next upgrade

A production/high-speed version should add encryption and RaptorQ:

```text
Flutter
  ├─ UI / camera orchestration
  └─ dart:ffi
       └─ Rust
           ├─ raptorq
           ├─ CRC / protocol
           └─ optional QR codec
```

## License

MIT
