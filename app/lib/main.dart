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

  @override
  Widget build(BuildContext context) {
    final fps = (_stats['fps'] as num?)?.toStringAsFixed(1) ?? '-';
    final ms = (_stats['inferMs'] as num?)?.toStringAsFixed(0) ?? '-';
    final hands = _stats['hands'] ?? '-';
    final pose = _stats['pose'] == true ? 'var' : 'yok';
    return Scaffold(
      appBar: AppBar(title: const Text('TİD Tanıma'), actions: [
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('${_front ? "Ön" : "Arka"} kamera   FPS: $fps   Çıkarım: $ms ms   El: $hands   Gövde: $pose'),
            ),
          ]),
      },
    );
  }
}
