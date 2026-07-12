import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/ui/core/command.dart';
import 'package:brewui/ui/home/home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBrewRepository implements BrewRepository {
  _FakeBrewRepository(this.result, {this.delay});

  BrewDetection result;
  Duration? delay;
  int detectCalls = 0;

  @override
  Future<BrewDetection> detect() async {
    detectCalls++;
    final wait = delay;
    if (wait != null) {
      await Future<void>.delayed(wait);
    }
    return result;
  }
}

Future<void> _waitFor(Command command) async {
  while (command.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('HomeViewModel', () {
    test('loads detection on construction', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitFor(viewModel.detect);

      expect(repository.detectCalls, 1);
      expect(viewModel.detection, isA<BrewFound>());
      expect(viewModel.detect.completed, isTrue);
      viewModel.dispose();
    });

    test('marks detect command running while awaiting repository', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
        delay: const Duration(milliseconds: 20),
      );
      final viewModel = HomeViewModel(brewRepository: repository);

      expect(viewModel.detect.running, isTrue);
      expect(viewModel.detection, isNull);

      await _waitFor(viewModel.detect);

      expect(viewModel.detect.running, isFalse);
      expect(viewModel.detection, isA<BrewFound>());
      viewModel.dispose();
    });

    test('refresh replaces detection with not-found', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitFor(viewModel.detect);
      expect(viewModel.detection, isA<BrewFound>());

      repository.result = const BrewNotFound();
      await viewModel.detect.execute();

      expect(viewModel.detection, isA<BrewNotFound>());
      expect(repository.detectCalls, 2);
      viewModel.dispose();
    });

    test('surfaces BrewDetectionError from repository', () async {
      final repository = _FakeBrewRepository(
        const BrewDetectionError('permission denied'),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitFor(viewModel.detect);

      expect(
        viewModel.detection,
        isA<BrewDetectionError>().having(
          (e) => e.message,
          'message',
          'permission denied',
        ),
      );
      viewModel.dispose();
    });
  });
}
