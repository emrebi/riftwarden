import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riftwarden/core/services/orientation_service.dart';

/// Acilis yon kapisinin mantigi.
///
/// Widget bilmez: sadece `dart:async` ve `ValueNotifier`/`VoidCallback`
/// icin `package:flutter/foundation.dart` kullanir.
class OrientationGateController {
  OrientationGateController({
    required this._service,
    required this._onReady,
    Duration timeout = const Duration(seconds: 10),
  }) : secondsLeft = ValueNotifier<int>(timeout.inSeconds);

  final OrientationService _service;
  final VoidCallback _onReady;

  /// Geri sayim: timeout saniyesinden 0'a iner.
  final ValueNotifier<int> secondsLeft;

  Timer? _timer;
  bool _proceeded = false;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = secondsLeft.value - 1;
      secondsLeft.value = next < 0 ? 0 : next;
      if (secondsLeft.value == 0) {
        proceed();
      }
    });
  }

  void onOrientationChanged({required bool isLandscape}) {
    if (isLandscape) {
      proceed();
    }
  }

  void onTap() => proceed();

  /// Sadece bir kez calisir: yon yataya kilitlenir ve [onReady] tetiklenir.
  Future<void> proceed() async {
    if (_proceeded) {
      return;
    }
    _proceeded = true;
    _timer?.cancel();
    await _service.lockLandscape();
    _onReady();
  }

  void dispose() {
    _timer?.cancel();
    secondsLeft.dispose();
  }
}
