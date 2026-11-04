# voice_note_chat_bar

A Flutter chat composer with **text send**, optional **attachment**, and **hold-to-record voice notes** (slide left to cancel).

## Features

- Attachment button (optional, default on) — you handle the tap (gallery, files, etc.)
- Text field with send on button or keyboard; mic when empty
- Hold ~220ms on mic → recording UI with live waveform
- Slide left to cancel, release to send (min 600ms, max 60s)
- `VoiceNoteChatBarTheme` Material 3 defaults + builders for mic, waveform, and recording bar
- Temp audio file deleted after `onVoiceNote` completes

## Demo

![VoiceNoteChatBar demo](https://github.com/ZainMughal329/voice_note_chat_bar/main/doc/demo.gif)

## Installation

```yaml
dependencies:
  voice_note_chat_bar: ^0.1.0
```

### Android

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### iOS

`ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need the microphone to record voice messages.</string>
```

## Usage

```dart
VoiceNoteChatBar(
  onSendText: (text) async {
    // send text
  },
  onVoiceNote: (result) async {
    // result.path, result.duration, result.file (XFile)
  },
  onAttachmentTap: () {
    // open your picker
  },
  onTextChanged: (text) {},
  clearOnSend: true,
  showAttachment: true,
)
```

### Required callbacks

| Callback | Description |
|----------|-------------|
| `onSendText` | `Future<void> Function(String text)` |
| `onVoiceNote` | `Future<void> Function(VoiceNoteResult result)` |
| `onAttachmentTap` | Required when `showAttachment: true` (default) |

### Customization

- `VoiceNoteChatBarTheme.material3(colorScheme)` or full `VoiceNoteChatBarTheme(...)`
- `micButtonBuilder: (context, child) => ...` — wrap default mic UI
- `waveformBuilder` / `recordingBarBuilder` — recording state
- `textFieldBuilder`, `attachmentBuilder`, `sendButtonBuilder`

## Example

```bash
cd example
flutter run
```

## License

MIT
