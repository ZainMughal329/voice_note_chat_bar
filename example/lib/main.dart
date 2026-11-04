import 'package:flutter/material.dart';
import 'package:voice_note_chat_bar/voice_note_chat_bar.dart';

void main() {
  runApp(const VoiceNoteChatBarExampleApp());
}

class VoiceNoteChatBarExampleApp extends StatelessWidget {
  const VoiceNoteChatBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceNoteChatBar',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VoiceNoteChatBar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Two demos: default Material 3 theme and a customized bar with builders.',
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Default bar'),
            subtitle: const Text('Theme defaults, attachment snackbar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DefaultBarDemoPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Custom bar'),
            subtitle: const Text('Builders + dark green accent'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CustomBarDemoPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DefaultBarDemoPage extends StatefulWidget {
  const DefaultBarDemoPage({super.key});

  @override
  State<DefaultBarDemoPage> createState() => _DefaultBarDemoPageState();
}

class _DefaultBarDemoPageState extends State<DefaultBarDemoPage> {
  final List<String> _log = [];

  void _addLog(String line) {
    setState(() => _log.insert(0, line));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Default')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _log.length,
              itemBuilder: (_, i) => Text(_log[i]),
            ),
          ),
          VoiceNoteChatBar(
            onSendText: (text) async {
              _addLog('Text: $text');
            },
            onVoiceNote: (result) async {
              _addLog(
                'Voice: ${result.duration.inMilliseconds}ms @ ${result.path}',
              );
            },
            onAttachmentTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attachment tapped — your picker here')),
              );
            },
            onTextChanged: (text) {},
          ),
        ],
      ),
    );
  }
}

class CustomBarDemoPage extends StatefulWidget {
  const CustomBarDemoPage({super.key});

  @override
  State<CustomBarDemoPage> createState() => _CustomBarDemoPageState();
}

class _CustomBarDemoPageState extends State<CustomBarDemoPage> {
  final List<String> _log = [];

  void _addLog(String line) {
    setState(() => _log.insert(0, line));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const accent = Color(0xFF1B7F5D);

    final theme = VoiceNoteChatBarTheme.material3(scheme).copyWith(
      slideToCancelHint: '← Slide to cancel',
    );

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: scheme.copyWith(primary: accent),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1419),
        appBar: AppBar(
          title: const Text('Custom builders'),
          backgroundColor: const Color(0xFF0F1419),
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _log.length,
                itemBuilder: (_, i) => Text(
                  _log[i],
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            VoiceNoteChatBar(
              theme: theme,
              micButtonBuilder: (context, child) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: child,
                );
              },
              waveformBuilder: (context, data) {
                return LiveRecordingWaveform(
                  levels: data.levels,
                  color: data.isCancelling ? Colors.orange : accent,
                  height: data.height,
                );
              },
              recordingBarBuilder: (context, data, waveform) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2229),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: data.isCancelling ? Colors.orange : accent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        data.isCancelling ? Icons.close : Icons.fiber_manual_record,
                        color: data.isCancelling ? Colors.orange : accent,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data.formattedTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: waveform),
                      Text(
                        data.hintText,
                        style: TextStyle(
                          color: data.isCancelling
                              ? Colors.orange
                              : Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
              onSendText: (text) async => _addLog('Custom text: $text'),
              onVoiceNote: (result) async {
                _addLog('Custom voice ${result.duration.inSeconds}s');
              },
              onAttachmentTap: () => _addLog('Custom attachment'),
            ),
          ],
        ),
      ),
    );
  }
}
