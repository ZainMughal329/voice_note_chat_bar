import 'package:flutter/material.dart';
import 'package:record/record.dart';

/// Visual and behavioral defaults for [VoiceNoteChatBar].
class VoiceNoteChatBarTheme {
  const VoiceNoteChatBarTheme({
    this.composerBackgroundColor,
    this.composerTopBorderColor,
    this.composerPadding = const EdgeInsets.fromLTRB(12, 12, 12, 12),
    this.composerTransitionDuration = const Duration(milliseconds: 180),
    this.attachmentButtonSize = 46,
    this.attachmentIcon = Icons.attach_file,
    this.attachmentButtonDecoration,
    this.attachmentIconColor,
    this.textFieldOuterDecoration,
    this.textFieldDecoration,
    this.textFieldHintText = 'Message...',
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 5,
    this.micButtonSize = 46,
    this.micIcon = Icons.mic_none_rounded,
    this.micButtonDecoration,
    this.micIconColor,
    this.sendButtonSize = 46,
    this.recordingCancelHintSpacing = 12,
    this.recordingCancelHintMaxWidth = 118,
    this.sendIcon = Icons.send_rounded,
    this.sendButtonDecoration,
    this.sendIconColor = Colors.white,
    this.recordingBarDecoration,
    this.recordingBarCancelDecoration,
    this.recordingDotColor = Colors.red,
    this.recordingDotCancelColor = Colors.redAccent,
    this.recordingTimerStyle,
    this.recordingTimerCancelColor = Colors.redAccent,
    this.recordingWaveformColor,
    this.recordingWaveformCancelColor = Colors.redAccent,
    this.recordingWaveformHeight = 30,
    this.recordingHintStyle,
    this.recordingHintCancelColor = Colors.redAccent,
    this.slideToCancelHint = 'Slide left to cancel',
    this.releaseToCancelHint = 'Release to cancel',
    this.holdToRecordDelay = const Duration(milliseconds: 220),
    this.cancelSlideThreshold = 56,
    this.minVoiceNoteDuration = const Duration(milliseconds: 600),
    this.maxVoiceNoteDuration = const Duration(seconds: 60),
    this.recordConfig = const RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    ),
    this.fileNamePrefix = 'voice_',
    this.fileExtension = '.m4a',
    this.waveformBarCount = 28,
  });

  /// Material 3–style neutral defaults from [ColorScheme].
  factory VoiceNoteChatBarTheme.material3(ColorScheme scheme) {
    final outline = scheme.outlineVariant;
    final onSurface = scheme.onSurface;
    final onSurfaceVariant = scheme.onSurfaceVariant;
    final primary = scheme.primary;
    final surface = scheme.surface;

    return VoiceNoteChatBarTheme(
      composerBackgroundColor: surface,
      composerTopBorderColor: outline.withValues(alpha: 0.7),
      attachmentButtonDecoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      attachmentIconColor: onSurface,
      textFieldOuterDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outline),
        color: scheme.surfaceContainerLowest,
      ),
      textFieldDecoration: InputDecoration(
        hintText: 'Message...',
        hintStyle: TextStyle(color: onSurfaceVariant, fontSize: 14),
        border: InputBorder.none,
      ),
      micButtonDecoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      micIconColor: onSurface,
      sendButtonDecoration: BoxDecoration(
        color: primary,
        shape: BoxShape.circle,
      ),
      recordingBarDecoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: onSurface.withValues(alpha: 0.18)),
      ),
      recordingBarCancelDecoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.45)),
      ),
      recordingTimerStyle: TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      recordingWaveformColor: onSurface,
      recordingHintStyle: TextStyle(color: onSurfaceVariant, fontSize: 11),
    );
  }

  final Color? composerBackgroundColor;
  final Color? composerTopBorderColor;
  final EdgeInsets composerPadding;
  final Duration composerTransitionDuration;

  final double attachmentButtonSize;
  final IconData attachmentIcon;
  final BoxDecoration? attachmentButtonDecoration;
  final Color? attachmentIconColor;

  final BoxDecoration? textFieldOuterDecoration;
  final InputDecoration? textFieldDecoration;
  final String textFieldHintText;
  final int textFieldMinLines;
  final int textFieldMaxLines;

  final double micButtonSize;
  final IconData micIcon;
  final BoxDecoration? micButtonDecoration;
  final Color? micIconColor;

  final double sendButtonSize;
  final IconData sendIcon;
  final BoxDecoration? sendButtonDecoration;
  final Color? sendIconColor;

  final BoxDecoration? recordingBarDecoration;
  final BoxDecoration? recordingBarCancelDecoration;
  final Color recordingDotColor;
  final Color recordingDotCancelColor;
  final TextStyle? recordingTimerStyle;
  final Color recordingTimerCancelColor;
  final Color? recordingWaveformColor;
  final Color recordingWaveformCancelColor;
  final double recordingWaveformHeight;
  /// Space between the live waveform and the slide-to-cancel hint.
  final double recordingCancelHintSpacing;
  /// Width reserved for the cancel hint so the waveform cannot overlap it.
  final double recordingCancelHintMaxWidth;
  final TextStyle? recordingHintStyle;
  final Color recordingHintCancelColor;
  final String slideToCancelHint;
  final String releaseToCancelHint;

  final Duration holdToRecordDelay;
  final double cancelSlideThreshold;
  final Duration minVoiceNoteDuration;
  final Duration maxVoiceNoteDuration;
  final RecordConfig recordConfig;
  final String fileNamePrefix;
  final String fileExtension;
  final int waveformBarCount;

  VoiceNoteChatBarTheme copyWith({
    Color? composerBackgroundColor,
    String? slideToCancelHint,
  }) {
    return VoiceNoteChatBarTheme(
      composerBackgroundColor:
          composerBackgroundColor ?? this.composerBackgroundColor,
      composerTopBorderColor: composerTopBorderColor,
      composerPadding: composerPadding,
      composerTransitionDuration: composerTransitionDuration,
      attachmentButtonSize: attachmentButtonSize,
      attachmentIcon: attachmentIcon,
      attachmentButtonDecoration: attachmentButtonDecoration,
      attachmentIconColor: attachmentIconColor,
      textFieldOuterDecoration: textFieldOuterDecoration,
      textFieldDecoration: textFieldDecoration,
      textFieldHintText: textFieldHintText,
      textFieldMinLines: textFieldMinLines,
      textFieldMaxLines: textFieldMaxLines,
      micButtonSize: micButtonSize,
      micIcon: micIcon,
      micButtonDecoration: micButtonDecoration,
      micIconColor: micIconColor,
      sendButtonSize: sendButtonSize,
      sendIcon: sendIcon,
      sendButtonDecoration: sendButtonDecoration,
      sendIconColor: sendIconColor,
      recordingBarDecoration: recordingBarDecoration,
      recordingBarCancelDecoration: recordingBarCancelDecoration,
      recordingDotColor: recordingDotColor,
      recordingDotCancelColor: recordingDotCancelColor,
      recordingTimerStyle: recordingTimerStyle,
      recordingTimerCancelColor: recordingTimerCancelColor,
      recordingWaveformColor: recordingWaveformColor,
      recordingWaveformCancelColor: recordingWaveformCancelColor,
      recordingWaveformHeight: recordingWaveformHeight,
      recordingCancelHintSpacing: recordingCancelHintSpacing,
      recordingCancelHintMaxWidth: recordingCancelHintMaxWidth,
      recordingHintStyle: recordingHintStyle,
      recordingHintCancelColor: recordingHintCancelColor,
      slideToCancelHint: slideToCancelHint ?? this.slideToCancelHint,
      releaseToCancelHint: releaseToCancelHint,
      holdToRecordDelay: holdToRecordDelay,
      cancelSlideThreshold: cancelSlideThreshold,
      minVoiceNoteDuration: minVoiceNoteDuration,
      maxVoiceNoteDuration: maxVoiceNoteDuration,
      recordConfig: recordConfig,
      fileNamePrefix: fileNamePrefix,
      fileExtension: fileExtension,
      waveformBarCount: waveformBarCount,
    );
  }
}
