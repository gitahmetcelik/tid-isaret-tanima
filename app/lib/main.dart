import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const TidApp());

class TidApp extends StatelessWidget {
  const TidApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TİD Tanıma',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const CameraScreen(),
      );
}

/// Kamera, MediaPipe ve model çıkarımı Kotlin'de çalışır; Flutter yalnızca görüntüyü gösterir,
/// özet olayları okur ve güven eşiğini uygular (PLAN.md P-05).
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  static const _control = MethodChannel('tid/control');
  static const _events = EventChannel('tid/landmarks');

  bool? _granted;
  bool _front = false;
  bool _continuous = false;
  bool _recording = false;
  double _threshold = 0.6; // ml/calibrate_threshold.py: 0.6'da kabul edilenlerde test doğruluğu ~%97
  int _mode = 1; // 0 hepsi CPU, 1 el GPU + poz CPU, 2 hepsi GPU
  Map<dynamic, dynamic> _stats = const {};
  Map<dynamic, dynamic>? _manual;
  String _last = '';
  int _rejected = 0;
  final List<String> _words = [];

  @override
  void initState() {
    super.initState();
    _control.invokeMethod<bool>('ensureCamera').then((ok) {
      if (!mounted) return;
      setState(() => _granted = ok ?? false);
      if (ok == true) {
        _events.receiveBroadcastStream().listen((e) {
          if (!mounted) return;
          final m = e as Map;
          if (m['segment'] != null) {
            _onSegment(m['segment'] as Map);
          } else {
            setState(() => _stats = m);
          }
        });
      }
    });
  }

  String _fmt(Map m) => '${m['name']} %${((m['p'] as double) * 100).toStringAsFixed(0)}';

  void _onSegment(Map seg) {
    setState(() {
      if (seg['error'] != null) {
        _last = '${seg['error']}';
        return;
      }
      final top = (seg['top'] as List).cast<Map>();
      if ((top.first['p'] as double) >= _threshold) {
        _words.add('${top.first['name']}');
        _last = _fmt(top.first);
      } else {
        _rejected++;
        _last = 'Emin değilim (en yakın: ${_fmt(top.first)})';
      }
    });
  }

  void _toggleLens() {
    setState(() => _front = !_front);
    _control.invokeMethod('setLens', _front);
  }

  void _setContinuous(bool c) {
    setState(() {
      _continuous = c;
      _recording = false;
      _manual = null;
    });
    _control.invokeMethod('setContinuous', c);
  }

  Future<void> _toggleRecord() async {
    if (!_recording) {
      setState(() {
        _recording = true;
        _manual = null;
      });
      await _control.invokeMethod('record', true);
    } else {
      setState(() => _recording = false);
      final r = await _control.invokeMethod<Map>('record', false);
      if (mounted) setState(() => _manual = r);
    }
  }

  Future<void> _selfTest() async {
    setState(() => _manual = {'error': 'Öz-test çalışıyor…'});
    final r = await _control.invokeMethod<Map>('selftest');
    if (!mounted) return;
    setState(() => _manual = {
          'error': r!['error'] ??
              'Öz-test: ${r['n']} örnek, doğruluk %${((r['accuracy'] as double) * 100).toStringAsFixed(1)}, '
                  'Python ile aynı tahmin %${((r['agreePython'] as double) * 100).toStringAsFixed(1)}, '
                  '${(r['msPerSample'] as double).toStringAsFixed(1)} ms/örnek'
        });
  }

  void _setMode(int m) {
    setState(() => _mode = m);
    _control.invokeMethod('setMode', m);
  }

  String _manualText() {
    if (_recording) return 'Kaydediliyor… ${_stats['recFrames'] ?? 0} kare. İşareti yapın, bitince "Bitir ve tanı"ya basın.';
    final r = _manual;
    if (r == null) return 'İşareti yapmadan önce kaydı başlatın.';
    if (r['error'] != null) return '${r['error']}';
    final top = (r['top'] as List).cast<Map>();
    final lines = top.map(_fmt).join('\n');
    return (top.first['p'] as double) < _threshold ? 'Emin değilim.\n$lines' : lines;
  }

  @override
  Widget build(BuildContext context) {
    final fps = (_stats['fps'] as num?)?.toStringAsFixed(1) ?? '-';
    String f0(String k) => (_stats[k] as num?)?.toStringAsFixed(0) ?? '-';
    final sides = (_stats['sides'] as String?)?.isEmpty ?? true ? 'yok' : _stats['sides'];
    final state = switch (_stats['state']) {
      'isaret' => 'İşaret algılanıyor…',
      'bekliyor' => 'Bekliyor (elleri kaldırın)',
      _ => '',
    };
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('TİD Tanıma'), actions: [
        IconButton(tooltip: 'Öz-test', icon: const Icon(Icons.fact_check), onPressed: _selfTest),
        IconButton(
          tooltip: _front ? 'Arka kameraya geç' : 'Ön kameraya geç',
          icon: Icon(_front ? Icons.camera_rear : Icons.camera_front),
          onPressed: _granted == true ? _toggleLens : null,
        ),
      ]),
      body: switch (_granted) {
        null => const Center(child: CircularProgressIndicator()),
        false => const Center(child: Text('Kamera izni gerekli.')),
        true => Column(children: [
            const Expanded(flex: 5, child: AndroidView(viewType: 'tid/camera_view')),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Elle kaydet'), icon: Icon(Icons.touch_app)),
                      ButtonSegment(value: true, label: Text('Sürekli'), icon: Icon(Icons.all_inclusive)),
                    ],
                    selected: {_continuous},
                    onSelectionChanged: (s) => _setContinuous(s.first),
                  ),
                  const SizedBox(height: 8),
                  if (_continuous) ...[
                    Text(state, style: theme.textTheme.labelLarge),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Metin', style: theme.textTheme.labelMedium),
                            const SizedBox(height: 4),
                            Text(_words.isEmpty ? '(henüz yok)' : _words.join(' '),
                                style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(_last.isEmpty ? '' : 'Son: $_last', style: theme.textTheme.bodyMedium),
                            Text('Reddedilen: $_rejected', style: theme.textTheme.bodySmall),
                          ]),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          _words.clear();
                          _last = '';
                          _rejected = 0;
                        }),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Temizle'),
                      ),
                    ),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(_manualText(), style: theme.textTheme.titleMedium),
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _toggleRecord,
                      icon: Icon(_recording ? Icons.stop : Icons.fiber_manual_record),
                      label: Text(_recording ? 'Bitir ve tanı' : 'İşareti kaydet'),
                      style: FilledButton.styleFrom(
                          backgroundColor: _recording ? Colors.red : null,
                          minimumSize: const Size.fromHeight(48)),
                    ),
                  ],
                  Row(children: [
                    Text('Güven eşiği %${(_threshold * 100).round()}'),
                    Expanded(
                      child: Slider(
                        min: 0.3,
                        max: 0.9,
                        divisions: 12,
                        value: _threshold,
                        onChanged: (v) => setState(() => _threshold = v),
                      ),
                    ),
                  ]),
                  ExpansionTile(
                    title: const Text('Hız ayarları ve ölçümler'),
                    tilePadding: EdgeInsets.zero,
                    children: [
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text('CPU')),
                          ButtonSegment(value: 1, label: Text('El GPU')),
                          ButtonSegment(value: 2, label: Text('GPU')),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (s) => _setMode(s.first),
                      ),
                      Text('${_stats['delegate'] ?? '-'}'),
                      Text('${_front ? "Ön" : "Arka"} kamera   FPS: $fps   Çıkarım: ${f0('inferMs')} ms   '
                          'El: ${_stats['hands'] ?? '-'} ($sides)   Gövde: ${_stats['pose'] == true ? 'var' : 'yok'}\n'
                          'Dönüşüm ${f0('convMs')} ms · El ${f0('handMs')} ms · Poz ${f0('poseMs')} ms · '
                          '${_stats['w'] ?? '-'}x${_stats['h'] ?? '-'}'),
                    ],
                  ),
                ]),
              ),
            ),
          ]),
      },
    );
  }
}
