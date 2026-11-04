import 'package:flutter_test/flutter_test.dart';
import 'package:voice_note_chat_bar/voice_note_chat_bar.dart';

void main() {
  test('VoiceNoteResult exposes XFile', () {
    const result = VoiceNoteResult(
      path: '/tmp/voice.m4a',
      duration: Duration(seconds: 3),
    );
    expect(result.file.path, '/tmp/voice.m4a');
    expect(result.duration.inSeconds, 3);
  });
}
