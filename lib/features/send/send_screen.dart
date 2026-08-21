import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/protocol/transfer_encoder.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/binary_qr_view.dart';
import '../../widgets/ferry_card.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  PreparedTransfer? _transfer;
  bool _preparing = false;
  bool _playing = false;
  int _frameIndex = 0;
  int _loops = 0;
  int _fps = 8;
  Timer? _timer;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (_preparing) return;

    setState(() {
      _preparing = true;
      _error = null;
      _transfer = null;
      _frameIndex = 0;
      _loops = 0;
    });

    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) {
        throw StateError('The selected file has no local path.');
      }

      final transfer = await TransferEncoder.prepareFile(File(path));

      if (!mounted) return;
      setState(() {
        _transfer = transfer;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _preparing = false;
        });
      }
    }
  }

  void _togglePlayback() {
    final transfer = _transfer;
    if (transfer == null) return;

    if (_playing) {
      _timer?.cancel();
      setState(() => _playing = false);
      return;
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: (1000 / _fps).round()), (_) {
      if (!mounted) return;

      setState(() {
        final next = _frameIndex + 1;
        if (next >= transfer.chunkCount) {
          _frameIndex = 0;
          _loops++;
        } else {
          _frameIndex = next;
        }
      });
    });

    setState(() => _playing = true);
  }

  void _setFps(int fps) {
    if (_fps == fps) return;

    final wasPlaying = _playing;
    _timer?.cancel();

    setState(() {
      _fps = fps;
      _playing = false;
    });

    if (wasPlaying) {
      _togglePlayback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transfer = _transfer;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, _) {
        _timer?.cancel();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Send',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            if (transfer != null)
              IconButton(
                tooltip: 'Choose another file',
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open_rounded),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: transfer == null ? _buildEmpty() : _buildTransfer(transfer),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        const SizedBox(height: 24),
        Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: const Color(0xFF14161B),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Center(
            child: _preparing
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 18),
                      Text('Preparing file…'),
                    ],
                  )
                : Icon(
                    Icons.file_present_rounded,
                    size: 70,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Choose a file to broadcast',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'The file stays on this device. It is converted into a repeating '
          'stream of binary QR frames.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 18),
          Text(
            _error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: _preparing ? null : _pickFile,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Choose file',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'MVP limit: ${TransferEncoder.maxFileBytes ~/ (1024 * 1024)} MB',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTransfer(PreparedTransfer transfer) {
    final currentFrame = transfer.frameAt(_frameIndex);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BinaryQrView(data: currentFrame, padding: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FerryCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      transfer.filename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    Formatters.bytes(transfer.originalSize),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.48),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_frameIndex + 1) / transfer.chunkCount,
                minHeight: 7,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Frame ${_frameIndex + 1} / ${transfer.chunkCount}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.52),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'loops $_loops',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.52),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (transfer.compressed) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.compress_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Compressed to ${Formatters.bytes(transfer.transmittedSize)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        FerryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Playback speed',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final fps in const [5, 8, 12]) ...[
                    Expanded(
                      child: _SpeedButton(
                        label: '$fps FPS',
                        selected: _fps == fps,
                        onTap: () => _setFps(fps),
                      ),
                    ),
                    if (fps != 12) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'If scanning struggles, reduce FPS or move the devices closer.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _togglePlayback,
          icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
          label: Text(
            _playing ? 'Pause stream' : 'Start stream',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)
          : Colors.white.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.62),
            ),
          ),
        ),
      ),
    );
  }
}
