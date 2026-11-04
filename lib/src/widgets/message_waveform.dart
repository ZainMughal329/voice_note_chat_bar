import 'package:flutter/material.dart';

/// Static or playback waveform bars.
class MessageWaveform extends StatelessWidget {
  const MessageWaveform({
    super.key,
    required this.bars,
    required this.color,
    this.height = 28,
    this.barWidth = 2.5,
    this.spacing = 2,
    this.progress = 1,
  });

  final List<double> bars;
  final Color color;
  final double height;
  final double barWidth;
  final double spacing;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barCount = bars.length;
        if (barCount == 0) {
          return SizedBox(height: height);
        }

        var effectiveBarWidth = barWidth;
        var effectiveSpacing = spacing;

        final maxWidth = constraints.maxWidth;
        if (maxWidth.isFinite && maxWidth > 0) {
          final naturalWidth =
              barCount * barWidth + (barCount - 1) * spacing;
          if (naturalWidth > maxWidth) {
            final scale = maxWidth / naturalWidth;
            effectiveBarWidth = barWidth * scale;
            effectiveSpacing = spacing * scale;
          }
        }

        return SizedBox(
          height: height,
          width: maxWidth.isFinite ? maxWidth : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (index) {
              final value = bars[index].clamp(0.12, 1.0);
              final played = index / barCount <= progress;
              return Padding(
                padding: EdgeInsets.only(
                  right: index == barCount - 1 ? 0 : effectiveSpacing,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: effectiveBarWidth,
                  height: height * value,
                  decoration: BoxDecoration(
                    color: played ? color : color.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Live amplitude bars while recording.
class LiveRecordingWaveform extends StatelessWidget {
  const LiveRecordingWaveform({
    super.key,
    required this.levels,
    required this.color,
    this.height = 32,
  });

  final List<double> levels;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bars = levels.isEmpty ? List<double>.filled(28, 0.2) : levels;
    return MessageWaveform(
      bars: bars,
      color: color,
      height: height,
      barWidth: 3,
      spacing: 2.5,
      progress: 1,
    );
  }
}
