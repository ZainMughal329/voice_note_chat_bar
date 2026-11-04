import 'package:cross_file/cross_file.dart';

/// Completed voice note passed to [VoiceNoteChatBar.onVoiceNote].
class VoiceNoteResult {
  const VoiceNoteResult({
    required this.path,
    required this.duration,
  });

  /// Absolute path to the recorded audio file (temporary directory).
  final String path;

  /// Recorded length (excluding hold-to-start delay).
  final Duration duration;

  /// Cross-platform file handle for uploads.
  XFile get file => XFile(path);
}
