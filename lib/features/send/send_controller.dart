import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/protocol/transfer_encoder.dart';

class SendController extends GetxController {
  final transfer = Rxn<PreparedTransfer>();
  final preparing = false.obs;
  final playing = false.obs;
  final frameIndex = 0.obs;
  final loops = 0.obs;
  final fps = 8.obs;
  final error = Rxn<String>();

  Timer? _timer;

  Future<void> pickFile() async {
    if (preparing.value) return;

    preparing.value = true;
    error.value = null;
    transfer.value = null;
    frameIndex.value = 0;
    loops.value = 0;
    _stopPlayback();

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

      transfer.value = await TransferEncoder.prepareFile(File(path));
    } catch (caughtError) {
      error.value = caughtError.toString();
    } finally {
      preparing.value = false;
    }
  }

  void togglePlayback() {
    final preparedTransfer = transfer.value;
    if (preparedTransfer == null) return;

    if (playing.value) {
      _stopPlayback();
      return;
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: (1000 / fps.value).round()),
      (_) => _advanceFrame(preparedTransfer),
    );
    playing.value = true;
  }

  void setFps(int value) {
    if (fps.value == value) return;

    final shouldResume = playing.value;
    _stopPlayback();
    fps.value = value;

    if (shouldResume) togglePlayback();
  }

  void _advanceFrame(PreparedTransfer preparedTransfer) {
    final next = frameIndex.value + 1;

    if (next >= preparedTransfer.chunkCount) {
      frameIndex.value = 0;
      loops.value++;
    } else {
      frameIndex.value = next;
    }
  }

  void _stopPlayback() {
    _timer?.cancel();
    _timer = null;
    playing.value = false;
  }

  @override
  void onClose() {
    _stopPlayback();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }
}
