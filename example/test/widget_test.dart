import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Example app smoke test', (tester) async {
    await tester.pumpWidget(const VoiceNoteChatBarExampleApp());
    expect(find.text('VoiceNoteChatBar'), findsOneWidget);
  });
}
