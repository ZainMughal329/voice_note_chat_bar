## 0.1.2

- Fix recording bar overlap: waveform scales to available width; cancel hint uses a reserved width column.

## 0.1.1

- Align mic and send trailing actions in a fixed slot (no layout shift).
- Default send button size matches mic (46px); send uses `InkWell` instead of `IconButton`.
- More space between recording waveform and cancel hint (`recordingCancelHintSpacing`).

## 0.1.0

- Initial release: `VoiceNoteChatBar` with hold-to-record, slide-to-cancel, and Material 3 theme defaults.
- Builders: `micButtonBuilder`, `waveformBuilder`, `recordingBarBuilder`, optional text/attachment/send builders.
- Example app with default and customized demos.
