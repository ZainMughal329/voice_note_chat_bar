import 'package:flutter/material.dart';

/// Data passed to [VoiceNoteChatBarWaveformBuilder].
class VoiceNoteWaveformData {
  const VoiceNoteWaveformData({
    required this.levels,
    required this.isCancelling,
    required this.color,
    required this.height,
  });

  final List<double> levels;
  final bool isCancelling;
  final Color color;
  final double height;
}

/// Data passed to [VoiceNoteChatBarRecordingBarBuilder].
class VoiceNoteRecordingBarData {
  const VoiceNoteRecordingBarData({
    required this.duration,
    required this.isCancelling,
    required this.formattedTime,
    required this.hintText,
    required this.dotColor,
    required this.timerStyle,
    required this.hintStyle,
  });

  final Duration duration;
  final bool isCancelling;
  final String formattedTime;
  final String hintText;
  final Color dotColor;
  final TextStyle timerStyle;
  final TextStyle hintStyle;
}

typedef VoiceNoteChatBarTextFieldBuilder =
    Widget Function(
      BuildContext context,
      TextEditingController controller,
      FocusNode focusNode,
      VoidCallback onSendSubmitted,
    );

typedef VoiceNoteChatBarAttachmentBuilder =
    Widget Function(BuildContext context, VoidCallback onTap);

typedef VoiceNoteChatBarSendButtonBuilder =
    Widget Function(BuildContext context, VoidCallback? onPressed);

typedef VoiceNoteChatBarMicButtonBuilder =
    Widget Function(BuildContext context, Widget child);

typedef VoiceNoteChatBarWaveformBuilder =
    Widget Function(BuildContext context, VoiceNoteWaveformData data);

typedef VoiceNoteChatBarRecordingBarBuilder =
    Widget Function(
      BuildContext context,
      VoiceNoteRecordingBarData data,
      Widget waveform,
    );
