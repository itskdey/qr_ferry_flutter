# QR Ferry

QR Ferry is a Flutter mobile app for transferring files directly between two devices with an animated stream of QR codes. One device turns a selected file into a repeating sequence of binary QR frames; the other device scans those frames, validates them, reconstructs the file, and saves it locally.

The transfer is fully offline. It does not require Wi-Fi, mobile data, Bluetooth, a cloud service, an account, or device pairing. The sender's screen and the receiver's camera are the transport channel.

> [!NOTE]
> This repository is an MVP focused on a small, understandable, pure-Dart transfer protocol. It is best suited to demonstrations and relatively small files, not high-speed production transfers.

## Features

- Pick any locally accessible file to send
- Transfer files up to 20 MB
- Compress with gzip when doing so saves at least 5% and 32 bytes
- Split data into 512-byte payload chunks by default
- Encode raw bytes in QR byte mode without Base64 expansion
- Play the QR sequence at 5, 8, or 12 frames per second
- Loop the stream until the receiver collects every frame
- Scan continuously with the device's rear camera
- Accept frames in any order and ignore duplicates
- Keep frames from different transfer sessions separate
- Validate each frame and the reconstructed payload with CRC32
- Restore compressed files automatically
- Sanitize filenames and avoid overwriting an existing received file
- Save received files in the app documents directory
- Export files with the platform share/save sheet
- Dark Material 3 interface with portrait orientation support

## How it works

```text
Sender                                          Receiver
------                                          --------
Select file
    |
Read bytes and calculate original CRC32
    |
Optionally gzip-compress
    |
Split into numbered chunks
    |
Add transfer metadata + frame CRC32
    |
Render repeating binary QR frames  ──────────>  Scan QR frames
                                                 |
                                                 Validate and deduplicate
                                                 |
                                                 Collect by chunk index
                                                 |
                                                 Validate transmitted CRC32
                                                 |
                                                 Decompress when required
                                                 |
                                                 Validate size + original CRC32
                                                 |
                                                 Save and share the file
```

Each transfer receives a 32-bit session identifier. Every frame repeats the metadata needed to identify and validate the transfer, so the receiver can begin scanning at any point in the loop. The receiver stores unique chunks by index; missing chunks are collected when the sender's animation loops again.

## Supported platforms

The repository currently includes native projects for:

- Android 7.0 or later (minimum SDK 24)
- iOS 13.0 or later

The camera permission is declared in the Android manifest and the iOS camera usage description is included in `Info.plist`. Desktop and web platform projects are not included.

## Requirements

- Flutter with Dart 3.11 or later
- Android Studio and the Android SDK for Android builds
- macOS with Xcode and CocoaPods for iOS builds
- Two physical devices for realistic end-to-end testing

A simulator can exercise most of the sender UI and the protocol tests, but receiving a live animated stream requires a usable camera.

## Getting started

Clone the repository and install the Flutter dependencies:

```bash
git clone <repository-url>
cd qr_ferry_flutter
flutter pub get
```

Check the local toolchain and connected devices:

```bash
flutter doctor
flutter devices
```

Run the app:

```bash
flutter run
```

To target a particular connected device:

```bash
flutter run -d <device-id>
```

No environment variables, API keys, backend, or external service configuration are required.

## Using QR Ferry

### Send a file

1. Open QR Ferry on the sending device.
2. Tap **Send a file** and choose a file.
3. Review the filename, size, frame count, and compression status.
4. Choose 5, 8, or 12 FPS.
5. Tap **Start stream** and keep the QR code visible.
6. Continue playback until the receiver reports that the transfer is complete.

Start with 8 FPS. Use 5 FPS if the receiving camera misses many frames; try 12 FPS when lighting, focus, screen quality, and camera performance are good.

### Receive a file

1. Open QR Ferry on the receiving device.
2. Tap **Receive a file** and grant camera access when prompted.
3. Point the rear camera at the sender and keep the entire QR code inside the guide.
4. Hold both devices steady while the unique-frame counter advances.
5. When the file is reconstructed, use **Share / Save** to export it or **Receive another** to reset the scanner.

The app first saves a completed transfer under `QR_Ferry_Received` in its application documents directory. If a file with the same name already exists, a suffix such as ` (1)` is added rather than overwriting it.

## Transfer protocol

Protocol version 1 uses a compact binary frame. All multi-byte integers are unsigned and encoded in little-endian byte order.

| Offset | Size | Field | Description |
| ---: | ---: | --- | --- |
| 0 | 4 | Magic | ASCII `FQR1` |
| 4 | 1 | Version | Currently `1` |
| 5 | 1 | Flags | Bit 0 indicates gzip compression |
| 6 | 4 | Session | Transfer session identifier |
| 10 | 4 | Chunk index | Zero-based index of this payload |
| 14 | 4 | Chunk count | Total number of chunks |
| 18 | 4 | Original size | File size before compression |
| 22 | 4 | Transmitted size | Byte count sent through QR frames |
| 26 | 4 | Original CRC32 | Checksum of the original file |
| 30 | 4 | Transmitted CRC32 | Checksum of the transmitted bytes |
| 34 | 1 | Filename length | UTF-8 filename size, up to 80 bytes |
| 35 | 2 | Payload length | Payload size in this frame |
| 37 | N | Filename | Sanitized UTF-8 filename |
| 37 + N | M | Payload | Binary chunk data |
| 37 + N + M | 4 | Frame CRC32 | Checksum of all preceding frame bytes |

The default payload size is 512 bytes. Internally, the encoder supports custom chunk sizes from 128 to 1,200 bytes. QR codes use the low error-correction level to leave more capacity for data.

### Integrity checks

QR Ferry uses three validation stages:

1. **Frame CRC32** rejects a corrupted individual frame before collection.
2. **Transmitted CRC32** verifies the complete joined payload before decompression.
3. **Original CRC32 and size** verify the final recovered file.

CRC32 detects accidental corruption; it is not a cryptographic integrity or authenticity mechanism.

## Performance

With the default 512-byte payload, the theoretical payload rates are:

| Playback rate | Theoretical payload rate |
| ---: | ---: |
| 5 FPS | 2,560 bytes/s |
| 8 FPS | 4,096 bytes/s |
| 12 FPS | 6,144 bytes/s |

Actual throughput is lower because every QR frame also carries metadata, cameras may skip frames, and QR detection takes time. Transfer time is affected by file compressibility, screen brightness, reflections, viewing angle, camera focus, device performance, distance, and playback speed.

Because this MVP sends numbered chunks rather than fountain-coded symbols, one missed frame can require waiting for the next full loop. Small files and compressible content therefore provide the best experience.

## Project structure

```text
lib/
├── main.dart                         # Flutter entry point and orientation
├── app.dart                          # GetMaterialApp and theme
├── routes/
│   ├── app_routes.dart               # Named route constants
│   └── app_pages.dart                # GetPage and binding registration
├── core/
│   ├── protocol/
│   │   ├── crc32.dart                # CRC32 implementation
│   │   ├── transfer_encoder.dart     # Compression and frame preparation
│   │   ├── transfer_frame.dart       # Binary frame serialization/parsing
│   │   └── transfer_receiver.dart    # Collection and reconstruction
│   └── utils/
│       └── formatters.dart           # Byte and percentage formatting
├── features/
│   ├── home/home_screen.dart         # Send/receive landing screen
│   ├── send/
│   │   ├── send_binding.dart         # Send dependency registration
│   │   ├── send_controller.dart      # File and playback state/lifecycle
│   │   └── send_screen.dart          # Reactive sender UI
│   └── receive/
│       ├── receive_binding.dart      # Receive dependency registration
│       ├── receive_controller.dart   # Scanner and recovery state/lifecycle
│       └── receive_screen.dart       # Reactive receiver UI
└── widgets/
    ├── binary_qr_view.dart           # Raw-byte QR renderer
    └── ferry_card.dart               # Shared card component

test/
├── protocol_test.dart                # CRC, frame, and reconstruction tests
└── getx_navigation_test.dart         # Route injection/disposal widget test
```

The protocol code is separated from the UI so that a future native or Rust codec can replace the current chunking strategy without requiring a complete interface rewrite. Application state uses GetX: named routes load feature-scoped bindings, `GetxController` classes own mutable state and resource lifecycles, and screens render reactive values with `Obx`. GetX removes each feature controller when its route closes.

## Main dependencies

| Package | Purpose |
| --- | --- |
| `get` | Reactive state, dependency injection, and named routing |
| `file_picker` | Select a local file on the sender |
| `qr` | Create QR matrices from binary data |
| `mobile_scanner` | Decode QR frames from the camera |
| `path_provider` | Locate the app documents directory |
| `share_plus` | Open the system share/save sheet |

Compression, isolates, file I/O, binary encoding, and CRC32 are handled with Dart libraries or project code.

## Development and testing

Format and statically analyze the project:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
```

Run the automated protocol tests:

```bash
flutter test
```

The current tests cover the standard CRC32 test vector, binary frame serialization/parsing with a Unicode filename, complete reconstruction from out-of-order frames, and GetX controller creation/disposal through named navigation.

Build release artifacts with the usual Flutter commands:

```bash
flutter build apk
flutter build appbundle
flutter build ios
```

Android release signing is not configured for production: the current release build type uses the debug signing configuration. Configure a private release key before publishing. iOS release builds require the appropriate Apple signing team and provisioning profile.

## Privacy and security

- File content is processed locally and the app contains no upload or network-transfer path.
- The visible QR stream is not encrypted. Anyone able to record or scan the complete stream can reconstruct the file.
- CRC32 protects against accidental corruption, not tampering, forgery, or malicious input.
- The receiver accepts the first valid transfer session it sees and ignores frames from other sessions until reset.
- Received filenames are sanitized before writing, and existing files are not overwritten.

Do not use this MVP to display sensitive files in an untrusted or observable environment.

## Current limitations

- Maximum input file size is 20 MB.
- There is no encryption, authentication, password protection, or sender verification.
- There is no RaptorQ/fountain coding or other forward-error correction across frames.
- Missing chunks are recovered only when the animation loops and displays them again.
- A receiver tracks one session at a time; use **Receive another** to reset it.
- Transfers are not resumable after the receiving screen or app is closed.
- The app has no background transfer mode.
- Only Android and iOS runners are included.
- Throughput is intentionally modest and varies significantly by hardware and environment.

## Troubleshooting

### The receiver is not detecting frames

- Keep the complete white QR square inside the scanning guide.
- Reduce playback to 5 FPS.
- Increase the sender's screen brightness and clean the receiver's camera lens.
- Avoid reflections and strong backlighting.
- Move the devices until the QR fills most of the guide while remaining in focus.
- Confirm that camera permission is enabled in the device settings.

### Progress stops before 100%

Leave the sender running. The sequence repeats, and the receiver will collect missing frames on a later loop. If progress remains stuck, lower the frame rate and adjust the camera position.

### A different transfer is ignored

The receiver locks onto the first valid session it detects. Complete or reset the current receive session before scanning another sender.

### iOS dependency or build errors

Run `flutter pub get`, then install pods from the `ios` directory if needed:

```bash
cd ios
pod install
cd ..
```

Open `ios/Runner.xcworkspace` rather than the `.xcodeproj` when working directly in Xcode.

## Roadmap

Potential production-oriented improvements include:

- RaptorQ or another fountain code for loss-tolerant reception
- Authenticated encryption and an explicit receiver trust flow
- A native or Rust codec through `dart:ffi`
- Faster QR rendering and scanning pipelines
- Transfer cancellation, pause/resume, and persisted receive sessions
- Benchmarks across devices, file types, QR sizes, and frame rates
- Expanded unit, widget, integration, fuzz, and corrupted-input tests

## License

This project is available under the [MIT License](LICENSE).
