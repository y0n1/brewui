import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';
import 'package:brewui/ui/core/command.dart';
import 'package:brewui/ui/home/home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBrewRepository implements BrewRepository {
  _FakeBrewRepository(
    this.detection, {
    this.installed = const BrewListSuccess([]),
    this.delay,
  });

  BrewDetection detection;
  BrewListResult installed;
  Duration? delay;
  int detectCalls = 0;
  int listCalls = 0;
  String? lastListExecutable;

  @override
  Future<BrewDetection> detect() async {
    detectCalls++;
    final wait = delay;
    if (wait != null) {
      await Future<void>.delayed(wait);
    }
    return detection;
  }

  @override
  Future<BrewListResult> listInstalledFormulae(String executable) async {
    listCalls++;
    lastListExecutable = executable;
    return installed;
  }
}

Future<void> _waitFor(Command command) async {
  while (command.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _waitForDetectAndList(HomeViewModel viewModel) async {
  await _waitFor(viewModel.detect);
  if (viewModel.detection is BrewFound) {
    // loadInstalled may start after detect notifies; give it a tick.
    await Future<void>.delayed(Duration.zero);
    await _waitFor(viewModel.loadInstalled);
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
      await _waitForDetectAndList(viewModel);

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

      await _waitForDetectAndList(viewModel);

      expect(viewModel.detect.running, isFalse);
      expect(viewModel.detection, isA<BrewFound>());
      viewModel.dispose();
    });

    test('loads installed formulae after BrewFound', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
        installed: const BrewListSuccess(['git', 'curl']),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndList(viewModel);

      expect(repository.listCalls, 1);
      expect(repository.lastListExecutable, '/opt/homebrew/bin/brew');
      expect(
        viewModel.installed,
        isA<BrewListSuccess>().having((r) => r.names, 'names', ['git', 'curl']),
      );
      viewModel.dispose();
    });

    test('does not list formulae when brew is not found', () async {
      final repository = _FakeBrewRepository(const BrewNotFound());
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndList(viewModel);

      expect(repository.listCalls, 0);
      expect(viewModel.installed, isNull);
      viewModel.dispose();
    });

    test('refresh replaces detection with not-found', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
        installed: const BrewListSuccess(['git']),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndList(viewModel);
      expect(viewModel.detection, isA<BrewFound>());
      expect(viewModel.installed, isA<BrewListSuccess>());

      repository.detection = const BrewNotFound();
      await viewModel.detect.execute();
      await _waitForDetectAndList(viewModel);

      expect(viewModel.detection, isA<BrewNotFound>());
      expect(viewModel.installed, isNull);
      expect(repository.detectCalls, 2);
      expect(repository.listCalls, 1);
      viewModel.dispose();
    });

    test('surfaces BrewDetectionError from repository', () async {
      final repository = _FakeBrewRepository(
        const BrewDetectionError('permission denied'),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndList(viewModel);

      expect(
        viewModel.detection,
        isA<BrewDetectionError>().having(
          (e) => e.message,
          'message',
          'permission denied',
        ),
      );
      expect(repository.listCalls, 0);
      viewModel.dispose();
    });

    test('surfaces BrewListError from repository', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
        installed: const BrewListError('database locked'),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndList(viewModel);

      expect(
        viewModel.installed,
        isA<BrewListError>().having(
          (e) => e.message,
          'message',
          'database locked',
        ),
      );
      viewModel.dispose();
    });
  });
}
