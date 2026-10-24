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

/// M0 iskeleti: kamera + MediaPipe el/poz noktaları Kotlin'de çalışır,
/// Flutter yalnızca görüntüyü gösterir ve FPS özetini okur (PLAN.md P-05).
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
  bool _recording = false;
  Map<dynamic, dynamic>? _result;
  int _mode = 1; // 0 hepsi CPU, 1 el GPU + poz CPU, 2 hepsi GPU
  Map<dynamic, dynamic> _stats = const {};

  @override
  void initState() {
    super.initState();
    _control.invokeMethod<bool>('ensureCamera').then((ok) {
      if (!mounted) return;
      setState(() => _granted = ok ?? false);
      if (ok == true) {
        _events.receiveBroadcastStream().listen((e) {
          if (mounted) setState(() => _stats = e as Map);
        });
      }
    });
  }

  void _toggleLens() {
    setState(() => _front = !_front);
    _control.invokeMethod('setLens', _front);
  }

  Future<void> _toggleRecord() async {
    if (!_recording) {
      setState(() { _recording = true; _result = null; });
      await _control.invokeMethod('record', true);
    } else {
      setState(() => _recording = false);
      final r = await _control.invokeMethod<Map>('record', false);
      if (mounted) setState(() => _result = r);
    }
  }

  Future<void> _selfTest() async {
    setState(() => _result = {'error': 'Öz-test çalışıyor…'});
    final r = await _control.invokeMethod<Map>('selftest');
    if (!mounted) return;
    setState(() => _result = {
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

  @override
  Widget build(BuildContext context) {
    final fps = (_stats['fps'] as num?)?.toStringAsFixed(1) ?? '-';
    final ms = (_stats['inferMs'] as num?)?.toStringAsFixed(0) ?? '-';
    final hands = _stats['hands'] ?? '-';
    final sides = (_stats['sides'] as String?)?.isEmpty ?? true ? 'yok' : _stats['sides'];
    String f0(String k) => (_stats[k] as num?)?.toStringAsFixed(0) ?? '-';
    final detail = 'Dönüşüm ${f0('convMs')} ms · El ${f0('handMs')} ms · Poz ${f0('poseMs')} ms · ${_stats['w'] ?? '-'}x${_stats['h'] ?? '-'}';
    final pose = _stats['pose'] == true ? 'var' : 'yok';
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
            const Expanded(child: AndroidView(viewType: 'tid/camera_view')),
            _ResultCard(result: _result, recording: _recording, recFrames: _stats['recFrames']),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: FilledButton.icon(
                onPressed: _toggleRecord,
                icon: Icon(_recording ? Icons.stop : Icons.fiber_manual_record),
                label: Text(_recording ? 'Bitir ve tanı' : 'İşareti kaydet'),
                style: FilledButton.styleFrom(
                    backgroundColor: _recording ? Colors.red : null,
                    minimumSize: const Size.fromHeight(48)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('CPU')),
                  ButtonSegment(value: 1, label: Text('El GPU')),
                  ButtonSegment(value: 2, label: Text('GPU')),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => _setMode(s.first),
              ),
            ),
            Text('${_stats['delegate'] ?? '-'}'),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text('${_front ? "Ön" : "Arka"} kamera   FPS: $fps   Çıkarım: $ms ms   El: $hands ($sides)   Gövde: $pose\n$detail'),
            ),
          ]),
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.recording, required this.recFrames});

  final Map<dynamic, dynamic>? result;
  final bool recording;
  final Object? recFrames;

  @override
  Widget build(BuildContext context) {
    final String text;
    if (recording) {
      text = 'Kaydediliyor… ${recFrames ?? 0} kare. İşareti yapın, bitince "Bitir ve tanı"ya basın.';
    } else if (result == null) {
      text = 'İşareti yapmadan önce kaydı başlatın.';
    } else if (result!['error'] != null) {
      text = '${result!['error']}';
    } else {
      final top = (result!['top'] as List).cast<Map>();
      text = top
          .map((m) => '${m['name']}  %${((m['p'] as double) * 100).toStringAsFixed(0)}')
          .join('\n');
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: Text(text, style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
      ),
    );
  }
}
