import 'package:flutter/material.dart';
import 'package:pinyin_pro_flutter/pinyin_pro_flutter.dart';

void main() => runApp(const PinyinProApp());

class PinyinProApp extends StatelessWidget {
  const PinyinProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pinyin_pro_flutter example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController(text: '汉语拼音');
  String _output = '';

  void _convert() {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    final basic = pinyin(word);
    final numeric = pinyin(word, options: const PinyinOptions(toneType: ToneType.num));
    final noTone = pinyin(word, options: const PinyinOptions(toneType: ToneType.none));
    final initials = pinyin(word, options: const PinyinOptions(pattern: PinyinPattern.initial));
    final finals = pinyin(word, options: const PinyinOptions(pattern: PinyinPattern.final_));

    setState(() {
      _output = [
        'Symbol tones:  $basic',
        'Numeric tones: $numeric',
        'No tones:      $noTone',
        'Initials:      $initials',
        'Finals:        $finals',
      ].join('\n');
    });
  }

  @override
  void initState() {
    super.initState();
    _convert();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pinyin_pro_flutter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Chinese text',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _convert(),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _convert, child: const Text('Convert')),
            const SizedBox(height: 24),
            if (_output.isNotEmpty)
              _ResultCard(title: 'pinyin()', body: _output),
            const SizedBox(height: 16),
            const _DemoSection(),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection();

  @override
  Widget build(BuildContext context) {
    final demos = _buildDemos();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('More examples',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...demos.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ResultCard(title: d.title, body: d.body),
            )),
      ],
    );
  }

  List<({String title, String body})> _buildDemos() {
    return [
      (
        title: 'Tone sandhi (变调)',
        body: [
          '一路顺风 → ${pinyin('一路顺风', options: const PinyinOptions(toneSandhi: true))}',
          '不好    → ${pinyin('不好', options: const PinyinOptions(toneSandhi: true))}',
        ].join('\n'),
      ),
      (
        title: 'Surname mode (姓氏)',
        body: [
          '曾小贤 → ${pinyin('曾小贤', options: const PinyinOptions(surname: SurnameMode.head))}',
          '覃晓旭 → ${pinyin('覃晓旭', options: const PinyinOptions(surname: SurnameMode.head))}',
        ].join('\n'),
      ),
      (
        title: 'Multiple readings (多音字)',
        body: [
          '好 → ${pinyin('好', options: const PinyinOptions(multiple: true))}',
          '行 → ${pinyin('行', options: const PinyinOptions(multiple: true))}',
        ].join('\n'),
      ),
      (
        title: 'matchPinyin()',
        body: [
          "matchPinyin('中文拼音', 'zwpy') → ${matchPinyin('中文拼音', 'zwpy')}",
          "matchPinyin('中文拼音', 'abc')  → ${matchPinyin('中文拼音', 'abc')}",
        ].join('\n'),
      ),
      (
        title: 'convertPinyin()',
        body: [
          "numToSymbol: ${convertPinyin('pin1 yin1')}",
          "symbolToNum: ${convertPinyin('pīn yīn', format: ConvertFormat.symbolToNum)}",
          "toneNone:    ${convertPinyin('pīn yīn', format: ConvertFormat.toneNone)}",
        ].join('\n'),
      ),
      (
        title: 'getInitialAndFinal() / getFinalParts()',
        body: () {
          final (:initial, :final_) = getInitialAndFinal('guang');
          final (:head, :body, :tail) = getFinalParts('guang');
          return [
            'guang → initial: $initial, final: $final_',
            'guang → head: $head, body: $body, tail: $tail',
          ].join('\n');
        }(),
      ),
    ];
  }
}
