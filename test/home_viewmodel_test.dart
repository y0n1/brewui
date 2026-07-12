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
    this.outdated = const BrewListSuccess([]),
    this.delay,
  });

  BrewDetection detection;
  BrewListResult installed;
  BrewListResult outdated;
  Duration? delay;
  int detectCalls = 0;
  int listInstalledCalls = 0;
  int listOutdatedCalls = 0;
  String? lastInstalledExecutable;
  String? lastOutdatedExecutable;

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
    listInstalledCalls++;
    lastInstalledExecutable = executable;
    return installed;
  }

  @override
  Future<BrewListResult> listOutdatedFormulae(String executable) async {
    listOutdatedCalls++;
    lastOutdatedExecutable = executable;
    return outdated;
  }
}

Future<void> _waitFor(Command command) async {
  while (command.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _waitForDetectAndLists(HomeViewModel viewModel) async {
  await _waitFor(viewModel.detect);
  if (viewModel.detection is BrewFound) {
    // Lists may start after detect notifies; give them a tick.
    await Future<void>.delayed(Duration.zero);
    await _waitFor(viewModel.loadInstalled);
    await _waitFor(viewModel.loadOutdated);
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
      await _waitForDetectAndLists(viewModel);

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

      await _waitForDetectAndLists(viewModel);

      expect(viewModel.detect.running, isFalse);
      expect(viewModel.detection, isA<BrewFound>());
      viewModel.dispose();
    });

    test('loads installed and outdated formulae after BrewFound', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
        installed: const BrewListSuccess(['git', 'curl']),
        outdated: const BrewListSuccess(['openssl@3']),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndLists(viewModel);

      expect(repository.listInstalledCalls, 1);
      expect(repository.listOutdatedCalls, 1);
      expect(repository.lastInstalledExecutable, '/opt/homebrew/bin/brew');
      expect(repository.lastOutdatedExecutable, '/opt/homebrew/bin/brew');
      expect(
        viewModel.installed,
        isA<BrewListSuccess>().having((r) => r.names, 'names', ['git', 'curl']),
      );
      expect(
        viewModel.outdated,
        isA<BrewListSuccess>().having((r) => r.names, 'names', ['openssl@3']),
      );
      viewModel.dispose();
    });

    test('does not list formulae when brew is not found', () async {
      final repository = _FakeBrewRepository(const BrewNotFound());
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndLists(viewModel);

      expect(repository.listInstalledCalls, 0);
      expect(repository.listOutdatedCalls, 0);
      expect(viewModel.installed, isNull);
      expect(viewModel.outdated, isNull);
      viewModel.dispose();
    });

    test('refresh replaces detection with not-found', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
        installed: const BrewListSuccess(['git']),
        outdated: const BrewListSuccess(['curl']),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndLists(viewModel);
      expect(viewModel.detection, isA<BrewFound>());
      expect(viewModel.installed, isA<BrewListSuccess>());
      expect(viewModel.outdated, isA<BrewListSuccess>());

      repository.detection = const BrewNotFound();
      await viewModel.detect.execute();
      await _waitForDetectAndLists(viewModel);

      expect(viewModel.detection, isA<BrewNotFound>());
      expect(viewModel.installed, isNull);
      expect(viewModel.outdated, isNull);
      expect(repository.detectCalls, 2);
      expect(repository.listInstalledCalls, 1);
      expect(repository.listOutdatedCalls, 1);
      viewModel.dispose();
    });

    test('surfaces BrewDetectionError from repository', () async {
      final repository = _FakeBrewRepository(
        const BrewDetectionError('permission denied'),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndLists(viewModel);

      expect(
        viewModel.detection,
        isA<BrewDetectionError>().having(
          (e) => e.message,
          'message',
          'permission denied',
        ),
      );
      expect(repository.listInstalledCalls, 0);
      expect(repository.listOutdatedCalls, 0);
      viewModel.dispose();
    });

    test('surfaces BrewListError for installed from repository', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
        installed: const BrewListError('database locked'),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndLists(viewModel);

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

    test('surfaces BrewListError for outdated from repository', () async {
      final repository = _FakeBrewRepository(
        const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
        ),
        outdated: const BrewListError('fetch failed'),
      );
      final viewModel = HomeViewModel(brewRepository: repository);
      await _waitForDetectAndLists(viewModel);

      expect(
        viewModel.outdated,
        isA<BrewListError>().having(
          (e) => e.message,
          'message',
          'fetch failed',
        ),
      );
      viewModel.dispose();
    });
  });
}
