// OrientationGateController mantik testleri: sahte servis, gercek
// SystemChrome cagrisi yok. fake_async ile zaman ilerletilir.
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riftwarden/core/services/orientation_service.dart';
import 'package:riftwarden/features/orientation_gate/viewmodel/orientation_gate_controller.dart';

class _FakeOrientationService extends OrientationService {
  int lockLandscapeCallCount = 0;

  @override
  Future<void> lockLandscape() async {
    lockLandscapeCallCount++;
  }
}

void main() {
  group('OrientationGateController', () {
    test('10 sn dolunca lockLandscape ve onReady bir kez cagrilir', () {
      fakeAsync((async) {
        final service = _FakeOrientationService();
        var onReadyCount = 0;
        final controller = OrientationGateController(
          service: service,
          onReady: () => onReadyCount++,
        );
        controller.start();

        async.elapse(const Duration(seconds: 10));

        expect(controller.secondsLeft.value, 0);
        expect(service.lockLandscapeCallCount, 1);
        expect(onReadyCount, 1);

        controller.dispose();
      });
    });

    test('onOrientationChanged(true) aninda proceed eder, sure dolsa da '
        'onReady tekrar cagrilmaz', () {
      fakeAsync((async) {
        final service = _FakeOrientationService();
        var onReadyCount = 0;
        final controller = OrientationGateController(
          service: service,
          onReady: () => onReadyCount++,
        );
        controller.start();

        controller.onOrientationChanged(isLandscape: true);
        async.flushMicrotasks();

        expect(onReadyCount, 1);
        expect(service.lockLandscapeCallCount, 1);

        async.elapse(const Duration(seconds: 10));

        expect(onReadyCount, 1);
        expect(service.lockLandscapeCallCount, 1);

        controller.dispose();
      });
    });

    test('onTap() aninda proceed eder', () {
      fakeAsync((async) {
        final service = _FakeOrientationService();
        var onReadyCount = 0;
        final controller = OrientationGateController(
          service: service,
          onReady: () => onReadyCount++,
        );
        controller.start();

        controller.onTap();
        async.flushMicrotasks();

        expect(onReadyCount, 1);
        expect(service.lockLandscapeCallCount, 1);

        controller.dispose();
      });
    });

    test('onOrientationChanged(false) hicbir sey yapmaz', () {
      fakeAsync((async) {
        final service = _FakeOrientationService();
        var onReadyCount = 0;
        final controller = OrientationGateController(
          service: service,
          onReady: () => onReadyCount++,
        );
        controller.start();

        controller.onOrientationChanged(isLandscape: false);
        async.elapse(const Duration(seconds: 2));

        expect(onReadyCount, 0);
        expect(service.lockLandscapeCallCount, 0);
        expect(controller.secondsLeft.value, 8);

        controller.dispose();
      });
    });

    test('dispose() sonrasi timer calismaz', () {
      fakeAsync((async) {
        final service = _FakeOrientationService();
        var onReadyCount = 0;
        final controller = OrientationGateController(
          service: service,
          onReady: () => onReadyCount++,
        );
        controller.start();
        controller.dispose();

        async.elapse(const Duration(seconds: 10));

        expect(onReadyCount, 0);
        expect(service.lockLandscapeCallCount, 0);
      });
    });
  });
}
