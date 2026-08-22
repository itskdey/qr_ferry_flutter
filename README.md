<p align="center">
  <img src="assets/img/logo/app_logo.png" alt="QRFerry logo" width="108" />
</p>

<h1 align="center">QRFerry</h1>

<p align="center">
  <strong>Offline device-to-device file transfer through animated QR codes.</strong>
</p>

<p align="center">
  Move a file from one device to another using only a screen and a camera — no Wi-Fi, Bluetooth, cloud storage, account, backend, or pairing step required.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-Mobile-2F6DFF?style=flat-square&logo=flutter&logoColor=white" />
  <img alt="Dart" src="https://img.shields.io/badge/Dart-%3E%3D3.11-111820?style=flat-square&logo=dart&logoColor=white" />
  <img alt="Platforms" src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-E7FF54?style=flat-square&labelColor=111820&color=E7FF54" />
  <img alt="License" src="https://img.shields.io/badge/License-MIT-E7FF54?style=flat-square&labelColor=111820&color=E7FF54" />
</p>

<p align="center">
  <a href="docs/index.html"><strong>Landing page</strong></a>
  ·
  <a href="docs/privacy.html"><strong>Privacy policy</strong></a>
  ·
  <a href="https://github.com/itskdey/qr_ferry_flutter/issues"><strong>Issues</strong></a>
  ·
  <a href="LICENSE"><strong>License</strong></a>
</p>

---

## Overview

QRFerry experiments with a deliberately simple transport model: **visible light**.

The sending device reads a local file, optionally compresses it, breaks it into numbered binary chunks, and renders those chunks as a repeating stream of QR frames. The receiving device watches that stream through its camera, collects valid frames in any order, reconstructs the original bytes, verifies integrity, and saves the recovered file locally.

The sender's **display** and the receiver's **camera** are the transport channel.

> [!NOTE]
> QRFerry is currently an MVP intended for experiments, learning, demos, air-gapped workflows, and relatively small files. It is not designed to replace a high-speed network transfer protocol.

## App preview

<p align="center">
  <img src="https://raw.githubusercontent.com/itskdey/qr_ferry_flutter/transfer-telemetry-ui/assets/screenshot/home_screenshot.png" alt="QRFerry home screen" width="290" />
</p>

<table>
  <tr>
    <td align="center"><strong>Prepare</strong></td>
    <td align="center"><strong>Broadcast</strong></td>
    <td align="center"><strong>Receive</strong></td>
    <td align="center"><strong>Verified</strong></td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/itskdey/qr_ferry_flutter/transfer-telemetry-ui/assets/screenshot/sender_screenshot.png" alt="QRFerry sender setup" width="210" />
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/itskdey/qr_ferry_flutter/transfer-telemetry-ui/assets/screenshot/sender_qr_screenshot.png" alt="QRFerry QR broadcast" width="210" />
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/itskdey/qr_ferry_flutter/transfer-telemetry-ui/assets/screenshot/receive_screenshot.png" alt="QRFerry receiver scanner" width="210" />
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/itskdey/qr_ferry_flutter/transfer-telemetry-ui/assets/screenshot/done_screenshot.png" alt="QRFerry completed transfer" width="210" />
    </td>
  </tr>
</table>

The interface uses an optical-tool / editorial visual language: warm paper-grid surfaces, near-black technical panels, signal-lime highlights, hard offset shadows, monospace metadata, and high-contrast typography.

## Why QRFerry?

Most file-transfer tools rely on at least one shared dependency: a local network, internet connection, discovery service, account, pairing workflow, cable, or backend.

QRFerry explores a different constraint: **what if the file itself could cross the gap through the camera?**

That makes the project useful for exploring:

- air-gapped and network-restricted transfer concepts
- binary QR byte-mode transport
- continuous camera decoding
- packet framing and integrity validation
- out-of-order chunk reconstruction
- duplicate-frame handling
- local-first Flutter architecture
- optical-channel UX and performance

## Highlights

| Area | What QRFerry does |
| --- | --- |
| **Transport** | Sends raw binary data through animated QR frames instead of a socket or cloud upload |
| **Local-first** | No QRFerry account, application backend, API key, or cloud storage is required |
| **Sender** | Picks a local file, optionally gzip-compresses it, chunks it, and broadcasts a repeating QR stream |
| **Receiver** | Continuously decodes QR bytes, accepts chunks in any order, ignores duplicates, reconstructs and verifies the file |
| **Integrity** | Uses per-frame CRC32, transmitted-payload CRC32, and final-file CRC32/size checks |
| **Playback** | Supports 5 FPS, 8 FPS, and 12 FPS broadcast presets |
| **Preview** | Lets the receiver inspect supported text, code, and image files before export |
| **Export** | Uses the native system share/save sheet after a verified transfer |
| **UI** | Provides live transfer state, progress, frame position, loop count, file metadata, and protocol-oriented details |

## How it works

```text
SENDER                                              RECEIVER

Local file                                           Camera
   │                                                   │
   ▼                                                   ▼
Read bytes                                      Decode QR bytes
   │                                                   │
   ├── CRC32                                           ├── Validate frame
   │                                                   │
   ▼                                                   ▼
Try gzip compression                            Deduplicate chunks
   │                                                   │
   ▼                                                   ▼
Split into numbered chunks                       Reassemble by index
   │                                                   │
   ▼                                                   ▼
Add metadata + CRC32                             Verify transmitted CRC32
   │                                                   │
   ▼                                                   ▼
Render binary QR frame   ───── visible light ─────► Decompress if needed
                                                       │
                                                       ▼
                                                Verify original file
                                                       │
                                                       ▼
                                                Preview / Save / Share
```

Each transfer has a 32-bit session identifier. Transfer metadata is repeated in every frame, so the receiver can begin scanning after the sender has already started broadcasting. Missed frames are recovered when the sender loops through the sequence again.

## Transfer characteristics

| Property | Current implementation |
| --- | --- |
| Maximum source file | **20 MB** |
| Default payload chunk | **512 bytes** |
| Supported internal chunk range | **128–1,200 bytes** |
| Broadcast presets | **5 / 8 / 12 FPS** |
| Compression | gzip, kept only when it saves at least 5% and 32 bytes |
| QR payload | Raw QR byte mode, not Base64 |
| Session identifier | 32-bit |
| Integrity | CRC32 at frame, transmitted-payload, and original-file levels |

### Approximate payload ceiling

Ignoring QR headers, metadata, camera losses, and decoding overhead, a 512-byte payload gives these theoretical rates:

| Playback | Raw payload per second |
| ---: | ---: |
| 5 FPS | 2,560 B/s |
| 8 FPS | 4,096 B/s |
| 12 FPS | 6,144 B/s |

Real transfer speed is lower and depends strongly on camera focus, screen brightness, viewing angle, reflections, device performance, file compressibility, and selected FPS.

## Received-file preview

After a successful transfer, QRFerry can inspect supported content before the user exports it.

| File type | Preview behavior |
| --- | --- |
| JPG, JPEG, PNG, GIF, WebP, BMP | Inline image preview with fullscreen viewing |
| TXT, Markdown, JSON, CSV, XML, YAML, logs | Scrollable selectable text |
| Dart, JS/TS, HTML/CSS, Python, Java, Kotlin, Swift, C/C++, Rust, Go, SQL, shell | Monospace source preview |
| PDF | File metadata / type card |
| Video | File metadata / type card |
| Audio | File metadata / type card |
| ZIP, RAR, 7z, TAR, GZ | Archive metadata / type card |
| Other binary files | Generic filename, type, and size card |

Large text documents are intentionally previewed with bounded content rather than rendering the entire file at once.

## Getting started

### Requirements

- Flutter with Dart **3.11 or later**
- Android Studio + Android SDK for Android development
- macOS + Xcode + CocoaPods for iOS development
- A physical device with a camera for realistic receiver testing

Current native targets:

- **Android:** minimum SDK 24 / Android 7.0+
- **iOS:** 13.0+

### Clone and run

```bash
git clone https://github.com/itskdey/qr_ferry_flutter.git
cd qr_ferry_flutter
flutter pub get
flutter run
```

No API keys, cloud credentials, backend configuration, or environment secrets are required.

### Run on a specific device

```bash
flutter devices
flutter run -d <device-id>
```

## Usage

### Send

1. Open QRFerry on the sending device.
2. Choose **Send a file**.
3. Select a local file.
4. Start with **Balanced / 8 FPS**.
5. Start the QR stream.
6. Keep the sender screen visible until the receiving device reaches 100%.

### Receive

1. Open QRFerry on the receiving device.
2. Choose **Receive a file**.
3. Grant camera permission when requested.
4. Point the camera at the complete QR code on the sender.
5. Keep both devices steady while unique frames are collected.
6. Wait for final verification.
7. Preview the recovered file, then save or share it.

> [!TIP]
> If decoding stalls, reduce the sender to **5 FPS**, increase screen brightness, keep the full QR margin visible, and keep both devices square to each other.

## Protocol v1

QRFerry currently uses a compact numbered-chunk protocol identified by the magic value `FQR1`.

Every frame carries enough metadata for the receiver to identify and validate the transfer, including:

- protocol version and flags
- transfer session ID
- chunk index and total chunk count
- original and transmitted file sizes
- original and transmitted CRC32 values
- UTF-8 filename
- binary payload
- per-frame CRC32

Multi-byte integer values are encoded in little-endian order.

### Integrity model

QRFerry performs three separate integrity checks:

1. **Frame CRC32** — rejects an individually corrupted QR frame.
2. **Transmitted CRC32** — validates the reconstructed transmitted payload before decompression.
3. **Original size + CRC32** — validates the final recovered file.

> [!IMPORTANT]
> CRC32 is an error-detection mechanism. It is **not encryption, authentication, or cryptographic tamper protection**.

## Architecture

The protocol layer is intentionally separated from the UI so the transport implementation can evolve without requiring a complete interface rewrite.

```text
lib/
├── main.dart
├── app.dart
├── routes/
│   ├── app_pages.dart
│   └── app_routes.dart
├── core/
│   ├── protocol/
│   │   ├── crc32.dart
│   │   ├── transfer_encoder.dart
│   │   ├── transfer_frame.dart
│   │   └── transfer_receiver.dart
│   └── utils/
├── features/
│   ├── home/
│   ├── send/
│   ├── receive/
│   └── details/
└── widgets/
    ├── binary_qr_view.dart
    └── qrferry_design.dart
```

### Main dependencies

| Package | Purpose |
| --- | --- |
| `get` | Navigation, dependency injection, reactive state |
| `file_picker` | Native file selection |
| `qr` | Binary QR matrix generation |
| `mobile_scanner` | Camera scanning and raw decoded QR bytes |
| `path_provider` | Application storage paths |
| `share_plus` | Native share/save sheet |
| `google_fonts` | Typography support |

Compression, CRC32, binary serialization, isolates, transfer reconstruction, and preview logic are implemented in Dart/Flutter and project code.

## Privacy & security

QRFerry does not use a file-upload backend. File content is read, encoded, decoded, reconstructed, previewed, and saved locally.

However, **offline does not mean secret**:

- the visible QR stream is currently unencrypted
- someone able to record enough QR frames may be able to reconstruct the file
- CRC32 protects against accidental corruption, not malicious modification
- there is currently no sender identity verification or receiver authentication

Do not display sensitive transfers where untrusted people or cameras can observe the sender screen.

See the full [Privacy Policy](docs/privacy.html).

## Current limitations

QRFerry is intentionally small and experimental. The current MVP has several known constraints:

- 20 MB maximum source file
- no RaptorQ or other forward-error-correction layer
- no encryption or password protection
- no sender/receiver authentication
- no resumable persisted receive session
- no background transfer mode
- no transfer history
- missed numbered chunks may require waiting for the next sender loop
- PDF page rendering is not yet implemented
- video/audio playback previews are not yet implemented
- Android and iOS are the current application targets

## Development

Format and analyze:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
```

Run tests:

```bash
flutter test
```

Build:

```bash
flutter build apk
flutter build appbundle
flutter build ios
```

> [!WARNING]
> Before publishing your own Android build, configure an appropriate release keystore and signing setup.

## Contributing

Issues, bug reports, performance observations, protocol experiments, and focused pull requests are welcome.

When reporting transfer problems, useful details include:

- sender and receiver device models
- OS versions
- file type and size
- selected FPS
- lighting / viewing conditions
- approximate progress when the failure occurred
- whether lowering the FPS changed the result

Open an issue: **https://github.com/itskdey/qr_ferry_flutter/issues**

## License

QRFerry is released under the [MIT License](LICENSE).

---

<p align="center">
  <strong>QRFerry</strong><br />
  Device-to-device optical file transfer, built with Flutter.
</p>
