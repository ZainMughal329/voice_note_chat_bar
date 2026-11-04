import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:voice_note_chat_bar/src/theme/voice_note_chat_bar_theme.dart';

/// Holds microphone recording state and gesture handling for [VoiceNoteChatBar].
class VoiceRecorderHandle {
  VoiceRecorderHandle({
    required this.theme,
    required this.onStateChanged,
    this.enableHaptics = true,
    this.onMicrophonePermissionDenied,
  });

  VoiceNoteChatBarTheme theme;
  final VoidCallback onStateChanged;
  final bool enableHaptics;
  final Future<void> Function()? onMicrophonePermissionDenied;

  /// Set by [VoiceNoteChatBar] to deliver completed recordings.
  Future<void> Function(VoiceRecorderFinishData data)? deliverVoiceNote;

  AudioRecorder _recorder = AudioRecorder();

  bool isRecording = false;
  bool isStartingRecord = false;
  bool isFinishingRecord = false;
  bool isCancelling = false;
  bool fingerDown = false;
  int? activePointer;
  Duration recordDuration = Duration.zero;
  Timer? recordTimer;
  Timer? longPressArmTimer;
  StreamSubscription<Amplitude>? amplitudeSub;
  List<double> liveLevels = [];
  String? recordingPath;
  Offset? recordOrigin;

  bool get isHolding => isRecording || isStartingRecord;

  Future<void> warmUpIfPermitted() async {
    if (!await Permission.microphone.isGranted) return;
    if (!await _recorder.hasPermission()) {
      await _recreateRecorder();
    }
  }

  Future<void> dispose() async {
    longPressArmTimer?.cancel();
    recordTimer?.cancel();
    await amplitudeSub?.cancel();
    amplitudeSub = null;
    await _disposeRecorderSafely();
  }

  Future<void> _disposeRecorderSafely() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
    try {
      await _recorder.dispose();
    } catch (_) {}
  }

  Future<void> _recreateRecorder() async {
    await _disposeRecorderSafely();
    _recorder = AudioRecorder();
  }

  Future<bool> ensureMicrophoneReady() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) {
      if (onMicrophonePermissionDenied != null) {
        await onMicrophonePermissionDenied!();
      }
      return false;
    }

    if (!await _recorder.hasPermission()) {
      await _recreateRecorder();
    }
    return _recorder.hasPermission();
  }

  void armHoldToRecord({required int pointer, required Offset origin}) {
    if (isRecording || isStartingRecord || isFinishingRecord) return;

    fingerDown = true;
    activePointer = pointer;
    recordOrigin = origin;
    isCancelling = false;

    longPressArmTimer?.cancel();
    longPressArmTimer = Timer(theme.holdToRecordDelay, () {
      if (!fingerDown || activePointer != pointer) return;
      unawaited(beginHoldToRecord(pointer: pointer, origin: origin));
    });
  }

  Future<void> beginHoldToRecord({
    required int pointer,
    required Offset origin,
  }) async {
    if (isRecording || isStartingRecord || isFinishingRecord) return;
    if (!fingerDown || activePointer != pointer) return;

    recordOrigin = origin;
    isCancelling = false;
    isStartingRecord = true;
    onStateChanged();

    try {
      final micReady = await ensureMicrophoneReady();
      if (!micReady) {
        resetRecordingFlags();
        return;
      }

      if (!fingerDown || activePointer != pointer) {
        resetRecordingFlags();
        return;
      }

      final dir = await getTemporaryDirectory();
      final path = p.join(
        dir.path,
        '${theme.fileNamePrefix}${DateTime.now().millisecondsSinceEpoch}${theme.fileExtension}',
      );

      await _recorder.start(theme.recordConfig, path: path);

      if (!fingerDown || activePointer != pointer) {
        try {
          await _recorder.stop();
        } catch (_) {}
        resetRecordingFlags();
        return;
      }

      _hapticMedium();

      liveLevels = List<double>.generate(
        theme.waveformBarCount,
        (_) => 0.18,
      );

      await amplitudeSub?.cancel();
      amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 90))
          .listen((amp) {
            if (!isRecording) return;
            final normalized = _normalizeAmplitude(amp.current);
            liveLevels.removeAt(0);
            liveLevels.add(normalized);
            onStateChanged();
          });

      recordTimer?.cancel();
      recordTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!isRecording) return;
        recordDuration += const Duration(milliseconds: 200);
        onStateChanged();
        if (recordDuration >= theme.maxVoiceNoteDuration) {
          unawaited(finishRecording(send: true));
        }
      });

      isRecording = true;
      isStartingRecord = false;
      isCancelling = false;
      recordDuration = Duration.zero;
      recordingPath = path;
      onStateChanged();
    } catch (_) {
      try {
        if (await _recorder.isRecording()) {
          await _recorder.stop();
        }
      } catch (_) {}
      resetRecordingFlags();
    }
  }

  void resetRecordingFlags() {
    isStartingRecord = false;
    isRecording = false;
    isCancelling = false;
    fingerDown = false;
    activePointer = null;
    recordOrigin = null;
    recordDuration = Duration.zero;
    onStateChanged();
  }

  void onPointerMove(PointerMoveEvent event) {
    if (activePointer != event.pointer) return;
    if (!isRecording && !isStartingRecord) return;
    if (recordOrigin == null) return;

    final dx = event.position.dx - recordOrigin!.dx;
    final cancelling = dx < -theme.cancelSlideThreshold;
    if (cancelling == isCancelling) return;

    isCancelling = cancelling;
    onStateChanged();
    if (cancelling) {
      _hapticWarning();
    }
  }

  void onPointerEnd(PointerEvent event) {
    if (activePointer != null && activePointer != event.pointer) return;

    final shouldCancel = isCancelling;
    final wasArmedOrRecording =
        isRecording ||
        isStartingRecord ||
        longPressArmTimer?.isActive == true;

    longPressArmTimer?.cancel();
    longPressArmTimer = null;
    fingerDown = false;
    activePointer = null;

    if (!wasArmedOrRecording) return;

    if (isStartingRecord) {
      return;
    }

    if (isRecording) {
      unawaited(finishRecording(send: !shouldCancel));
    }
  }

  Future<void> finishRecording({required bool send}) async {
    if (isFinishingRecord) return;
    if (!isRecording && !isStartingRecord) return;

    isFinishingRecord = true;
    final recordedFor = recordDuration;
    final pathBeforeStop = recordingPath;

    await stopRecordingInternal(discard: !send);

    isRecording = false;
    isStartingRecord = false;
    isCancelling = false;
    fingerDown = false;
    activePointer = null;
    recordOrigin = null;
    recordDuration = Duration.zero;
    onStateChanged();

    final shouldDeliver =
        send &&
        pathBeforeStop != null &&
        recordedFor >= theme.minVoiceNoteDuration;

    isFinishingRecord = false;

    if (!shouldDeliver) {
      if (pathBeforeStop != null) {
        await _deleteFile(pathBeforeStop);
      }
      return;
    }

    _hapticSuccess();

    final path = pathBeforeStop;
    final deliver = deliverVoiceNote;
    if (deliver != null) {
      await deliver(
        VoiceRecorderFinishData(path: path, duration: recordedFor),
      );
    }
    await _deleteFile(path);
  }

  Future<void> stopRecordingInternal({required bool discard}) async {
    recordTimer?.cancel();
    recordTimer = null;
    await amplitudeSub?.cancel();
    amplitudeSub = null;

    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        if (!discard) {
          recordingPath = path ?? recordingPath;
        }
      }
    } catch (_) {}
  }

  static Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  double _normalizeAmplitude(double db) {
    final clamped = db.clamp(-50.0, 0.0);
    final t = (clamped + 50) / 50;
    return (0.16 + (t * 0.84)).clamp(0.16, 1.0);
  }

  void _hapticMedium() {
    if (!enableHaptics) return;
    HapticFeedback.mediumImpact();
  }

  void _hapticWarning() {
    if (!enableHaptics) return;
    HapticFeedback.heavyImpact();
  }

  void _hapticSuccess() {
    if (!enableHaptics) return;
    HapticFeedback.mediumImpact();
  }

  static String formatRecordTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class VoiceRecorderFinishData {
  const VoiceRecorderFinishData({
    required this.path,
    required this.duration,
  });

  final String path;
  final Duration duration;
}
