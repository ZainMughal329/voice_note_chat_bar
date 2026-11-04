import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voice_note_chat_bar/src/builders/voice_note_chat_bar_builders.dart';
import 'package:voice_note_chat_bar/src/models/voice_note_result.dart';
import 'package:voice_note_chat_bar/src/theme/voice_note_chat_bar_theme.dart';
import 'package:voice_note_chat_bar/src/voice_recorder_handle.dart';
import 'package:voice_note_chat_bar/src/widgets/message_waveform.dart';

/// Chat composer: optional attachment, text field, send / hold-to-record voice.
class VoiceNoteChatBar extends StatefulWidget {
  const VoiceNoteChatBar({
    super.key,
    required this.onSendText,
    required this.onVoiceNote,
    this.onAttachmentTap,
    this.onTextChanged,
    this.onMicrophonePermissionDenied,
    this.controller,
    this.focusNode,
    this.theme,
    this.showAttachment = true,
    this.clearOnSend = true,
    this.enabled = true,
    this.isSendBusy = false,
    this.enableHaptics = true,
    this.textFieldBuilder,
    this.attachmentBuilder,
    this.sendButtonBuilder,
    this.micButtonBuilder,
    this.waveformBuilder,
    this.recordingBarBuilder,
  }) : assert(
         !showAttachment || onAttachmentTap != null,
         'onAttachmentTap is required when showAttachment is true',
       );

  final Future<void> Function(String text) onSendText;
  final Future<void> Function(VoiceNoteResult result) onVoiceNote;

  /// Required when [showAttachment] is true.
  final VoidCallback? onAttachmentTap;

  final ValueChanged<String>? onTextChanged;
  final Future<void> Function()? onMicrophonePermissionDenied;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final VoiceNoteChatBarTheme? theme;
  final bool showAttachment;
  final bool clearOnSend;
  final bool enabled;
  final bool isSendBusy;
  final bool enableHaptics;

  final VoiceNoteChatBarTextFieldBuilder? textFieldBuilder;
  final VoiceNoteChatBarAttachmentBuilder? attachmentBuilder;
  final VoiceNoteChatBarSendButtonBuilder? sendButtonBuilder;
  final VoiceNoteChatBarMicButtonBuilder? micButtonBuilder;
  final VoiceNoteChatBarWaveformBuilder? waveformBuilder;
  final VoiceNoteChatBarRecordingBarBuilder? recordingBarBuilder;

  @override
  State<VoiceNoteChatBar> createState() => _VoiceNoteChatBarState();
}

class _VoiceNoteChatBarState extends State<VoiceNoteChatBar> {
  late VoiceNoteChatBarTheme _theme;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late VoiceRecorderHandle _recorder;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _theme =
        widget.theme ??
        VoiceNoteChatBarTheme.material3(
          ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        );
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onControllerChanged);

    _recorder = VoiceRecorderHandle(
      theme: _theme,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      enableHaptics: widget.enableHaptics,
      onMicrophonePermissionDenied: widget.onMicrophonePermissionDenied,
    );
    _recorder.deliverVoiceNote = _deliverVoiceNote;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_recorder.warmUpIfPermitted());
    });
  }

  void _applyTheme(VoiceNoteChatBarTheme theme) {
    _theme = theme;
    _recorder.theme = theme;
  }

  @override
  void didUpdateWidget(covariant VoiceNoteChatBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recorder.deliverVoiceNote = _deliverVoiceNote;
    if (widget.theme != null) {
      _applyTheme(widget.theme!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.theme == null) {
      _applyTheme(VoiceNoteChatBarTheme.material3(Theme.of(context).colorScheme));
    }
  }

  void _onControllerChanged() {
    widget.onTextChanged?.call(_controller.text);
    setState(() {});
  }

  Future<void> _deliverVoiceNote(VoiceRecorderFinishData data) async {
    await widget.onVoiceNote(
      VoiceNoteResult(path: data.path, duration: data.duration),
    );
  }

  Future<void> _handleSendText() async {
    if (!widget.enabled || widget.isSendBusy) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await widget.onSendText(text);
    if (widget.clearOnSend && mounted) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    unawaited(_recorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final holding = _recorder.isHolding;
    final scheme = Theme.of(context).colorScheme;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: _recorder.onPointerMove,
      onPointerUp: _recorder.onPointerEnd,
      onPointerCancel: _recorder.onPointerEnd,
      child: Container(
        padding: _theme.composerPadding.copyWith(
          bottom: bottom > 0 ? bottom : _theme.composerPadding.bottom,
        ),
        decoration: BoxDecoration(
          color: _theme.composerBackgroundColor ?? scheme.surface,
          border: Border(
            top: BorderSide(
              color:
                  _theme.composerTopBorderColor ??
                  scheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: _theme.composerTransitionDuration,
          child: holding
              ? _buildRecordingBar(context)
              : _buildIdleComposer(context, key: const ValueKey('composer')),
        ),
      ),
    );
  }

  Widget _buildIdleComposer(BuildContext context, {required Key key}) {
    final hasText = _controller.text.trim().isNotEmpty;
    final canInteract = widget.enabled && !widget.isSendBusy;

    return Row(
      key: key,
      children: [
        if (widget.showAttachment) ...[
          _buildAttachment(context, canInteract),
          const SizedBox(width: 6),
        ],
        Expanded(child: _buildTextField(context, canInteract)),
        const SizedBox(width: 6),
        _buildTrailingAction(context, hasText: hasText, canInteract: canInteract),
      ],
    );
  }

  Widget _buildAttachment(BuildContext context, bool canInteract) {
    final onTap = canInteract ? widget.onAttachmentTap! : null;
    if (widget.attachmentBuilder != null) {
      return widget.attachmentBuilder!(
        context,
        onTap ?? () {},
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: _theme.attachmentButtonSize,
        height: _theme.attachmentButtonSize,
        decoration: _theme.attachmentButtonDecoration,
        child: Icon(
          _theme.attachmentIcon,
          color: _theme.attachmentIconColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, bool canInteract) {
    if (widget.textFieldBuilder != null) {
      return widget.textFieldBuilder!(
        context,
        _controller,
        _focusNode,
        _handleSendText,
      );
    }

    final decoration =
        _theme.textFieldDecoration ??
        InputDecoration(
          hintText: _theme.textFieldHintText,
          border: InputBorder.none,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _theme.textFieldOuterDecoration,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: canInteract,
        minLines: _theme.textFieldMinLines,
        maxLines: _theme.textFieldMaxLines,
        textInputAction: TextInputAction.send,
        onSubmitted: canInteract ? (_) => _handleSendText() : null,
        decoration: decoration,
      ),
    );
  }

  double get _trailingSlotSize {
    if (_theme.micButtonSize >= _theme.sendButtonSize) {
      return _theme.micButtonSize;
    }
    return _theme.sendButtonSize;
  }

  Widget _buildTrailingAction(
    BuildContext context, {
    required bool hasText,
    required bool canInteract,
  }) {
    final child = hasText
        ? _buildSendButton(context, canInteract)
        : _buildMicButton(context, canInteract);

    return SizedBox(
      width: _trailingSlotSize,
      height: _trailingSlotSize,
      child: Center(child: child),
    );
  }

  Widget _buildSendButton(BuildContext context, bool canInteract) {
    final onPressed = canInteract ? _handleSendText : null;
    if (widget.sendButtonBuilder != null) {
      return widget.sendButtonBuilder!(context, onPressed);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: _theme.sendButtonSize,
          height: _theme.sendButtonSize,
          decoration: _theme.sendButtonDecoration,
          child: Icon(
            _theme.sendIcon,
            color: _theme.sendIconColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton(BuildContext context, bool canInteract) {
    final defaultMic = Container(
      width: _theme.micButtonSize,
      height: _theme.micButtonSize,
      decoration: _theme.micButtonDecoration,
      child: Icon(
        _theme.micIcon,
        color: _theme.micIconColor,
        size: 24,
      ),
    );

    final child = widget.micButtonBuilder != null
        ? widget.micButtonBuilder!(context, defaultMic)
        : defaultMic;

    if (!canInteract) {
      return Opacity(opacity: 0.45, child: child);
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _recorder.armHoldToRecord(
          pointer: event.pointer,
          origin: event.position,
        );
      },
      child: child,
    );
  }

  Widget _buildRecordingBar(BuildContext context) {
    final isCancelling = _recorder.isCancelling;
    final scheme = Theme.of(context).colorScheme;
    final onSurface = _theme.recordingWaveformColor ?? scheme.onSurface;
    final waveColor = isCancelling
        ? _theme.recordingWaveformCancelColor
        : onSurface;

    final waveformData = VoiceNoteWaveformData(
      levels: List<double>.from(_recorder.liveLevels),
      isCancelling: isCancelling,
      color: waveColor,
      height: _theme.recordingWaveformHeight,
    );

    final defaultWaveform = LiveRecordingWaveform(
      levels: waveformData.levels,
      color: waveformData.color,
      height: waveformData.height,
    );

    final waveform = widget.waveformBuilder != null
        ? widget.waveformBuilder!(context, waveformData)
        : defaultWaveform;

    final timerStyle =
        _theme.recordingTimerStyle ??
        TextStyle(
          color: isCancelling
              ? _theme.recordingTimerCancelColor
              : onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );

    final hintStyle =
        _theme.recordingHintStyle ??
        TextStyle(
          color: isCancelling
              ? _theme.recordingHintCancelColor
              : scheme.onSurfaceVariant,
          fontSize: 11,
        );

    final barData = VoiceNoteRecordingBarData(
      duration: _recorder.recordDuration,
      isCancelling: isCancelling,
      formattedTime: VoiceRecorderHandle.formatRecordTime(
        _recorder.recordDuration,
      ),
      hintText: isCancelling
          ? _theme.releaseToCancelHint
          : _theme.slideToCancelHint,
      dotColor: isCancelling
          ? _theme.recordingDotCancelColor
          : _theme.recordingDotColor,
      timerStyle: timerStyle,
      hintStyle: hintStyle,
    );

    if (widget.recordingBarBuilder != null) {
      return KeyedSubtree(
        key: const ValueKey('recording'),
        child: widget.recordingBarBuilder!(context, barData, waveform),
      );
    }

    final decoration = isCancelling
        ? _theme.recordingBarCancelDecoration
        : _theme.recordingBarDecoration;

    return Container(
      key: const ValueKey('recording'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: decoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: barData.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(barData.formattedTime, style: barData.timerStyle),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                child: waveform,
              ),
            ),
          ),
          SizedBox(width: _theme.recordingCancelHintSpacing),
          SizedBox(
            width: _theme.recordingCancelHintMaxWidth,
            child: Text(
              barData.hintText,
              style: barData.hintStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
