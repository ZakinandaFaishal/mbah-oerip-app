import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

typedef ShakeCallback = void Function();

class ShakeDetector {
  final double threshold;
  final Duration minTimeBetweenShakes;
  final ShakeCallback onShake;

  StreamSubscription<UserAccelerometerEvent>? _sub;
  DateTime _lastShake = DateTime.fromMillisecondsSinceEpoch(0);

  ShakeDetector({
    required this.onShake,
    this.threshold = 18.0,
    this.minTimeBetweenShakes = const Duration(seconds: 2),
  });

  void start() {
    _sub ??= userAccelerometerEventStream().listen((e) {
      final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      final now = DateTime.now();
      if (mag > threshold &&
          now.difference(_lastShake) > minTimeBetweenShakes) {
        _lastShake = now;
        onShake();
      }
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
