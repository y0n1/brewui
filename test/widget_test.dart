import 'dart:async';

import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';
import 'package:brewui/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBrewRepository implements BrewRepository {
  _FakeBrewRepository(
    this._results, {
    this.installed = const BrewListSuccess([]),
    this.outdated = const BrewListSuccess([]),
  });

  final List<BrewDetection> _results;
  BrewListResult installed;
  BrewListResult outdated;
  int detectCalls = 0;
  int listInstalledCalls = 0;
  int listOutdatedCalls = 0;
  Completer<void>? gate;

  @override
  Future<BrewDetection> detect() async {
    detectCalls++;
    final pending = gate;
    if (pending != null) {
      await pending.future;
    }
    final index = detectCalls - 1;
    return _results[index.clamp(0, _results.length - 1)];
  }

  @override
  Future<BrewListResult> listInstalledFormulae(String executable) async {
    listInstalledCalls++;
    return installed;
  }

  @override
  Future<BrewListResult> listOutdatedFormulae(String executable) async {
    listOutdatedCalls++;
    return outdated;
  }
}

void main() {
  testWidgets('shows loading while detection is in progress', (tester) async {
    final repository = _FakeBrewRepository([
      const BrewFound(
        version: 'Homebrew 6.0.9',
        executablePath: '/opt/homebrew/bin/brew',
      ),
    ])..gate = Completer<void>();

    await tester.pumpWidget(BrewUiApp(brewRepository: repository));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Detecting Homebrew…'), findsOneWidget);

    repository.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Homebrew 6.0.9'), findsOneWidget);
  });

  testWidgets('shows compact status with version and path', (tester) async {
    await tester.pumpWidget(
      BrewUiApp(
        brewRepository: _FakeBrewRepository([
          const BrewFound(
            version: 'Homebrew 6.0.9',
            executablePath: '/opt/homebrew/bin/brew',
            prefix: '/opt/homebrew',
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Homebrew 6.0.9'), findsOneWidget);
    expect(
      find.text('/opt/homebrew/bin/brew  ·  prefix /opt/homebrew'),
      findsOneWidget,
    );
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('shows installed formulae names with count', (tester) async {
    await tester.pumpWidget(
      BrewUiApp(
        brewRepository: _FakeBrewRepository([
          const BrewFound(
            version: 'Homebrew 6.0.9',
            executablePath: '/opt/homebrew/bin/brew',
          ),
        ], installed: const BrewListSuccess(['curl', 'git'])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Installed formulae'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('curl'), findsOneWidget);
    expect(find.text('git'), findsOneWidget);
    expect(find.text('Install'), findsNothing);
    expect(find.text('Uninstall'), findsNothing);
  });

  testWidgets('shows outdated formulae names with count', (tester) async {
    await tester.pumpWidget(
      BrewUiApp(
        brewRepository: _FakeBrewRepository([
          const BrewFound(
            version: 'Homebrew 6.0.9',
            executablePath: '/opt/homebrew/bin/brew',
          ),
        ], outdated: const BrewListSuccess(['openssl@3', 'wget'])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Outdated formulae'), findsOneWidget);
    expect(find.text('openssl@3'), findsOneWidget);
    expect(find.text('wget'), findsOneWidget);
    expect(find.text('Upgrade'), findsNothing);
  });

  testWidgets('shows empty list messages and zero counts', (tester) async {
    await tester.pumpWidget(
      BrewUiApp(
        brewRepository: _FakeBrewRepository([
          const BrewFound(
            version: 'Homebrew 6.0.9',
            executablePath: '/opt/homebrew/bin/brew',
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No formulae installed.'), findsOneWidget);
    expect(find.text('No outdated formulae.'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('shows not-found state', (tester) async {
    await tester.pumpWidget(
      BrewUiApp(brewRepository: _FakeBrewRepository([const BrewNotFound()])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Homebrew not found'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Installed formulae'), findsNothing);
    expect(find.text('Outdated formulae'), findsNothing);
  });

  testWidgets('shows error state with message', (tester) async {
    await tester.pumpWidget(
      BrewUiApp(
        brewRepository: _FakeBrewRepository([
          const BrewDetectionError('permission denied'),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not detect Homebrew'), findsOneWidget);
    expect(find.text('permission denied'), findsOneWidget);
  });

  testWidgets('Retry re-runs detection', (tester) async {
    final repository = _FakeBrewRepository([
      const BrewNotFound(),
      const BrewFound(
        version: 'Homebrew 6.0.9',
        executablePath: '/opt/homebrew/bin/brew',
      ),
    ]);

    await tester.pumpWidget(BrewUiApp(brewRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Homebrew not found'), findsOneWidget);
    expect(repository.detectCalls, 1);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repository.detectCalls, 2);
    expect(find.text('Homebrew 6.0.9'), findsOneWidget);
  });

  testWidgets('Refresh re-runs detection from found state', (tester) async {
    final repository = _FakeBrewRepository([
      const BrewFound(
        version: 'Homebrew 6.0.9',
        executablePath: '/opt/homebrew/bin/brew',
      ),
    ]);

    await tester.pumpWidget(BrewUiApp(brewRepository: repository));
    await tester.pumpAndSettle();

    expect(repository.detectCalls, 1);
    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(repository.detectCalls, 2);
  });
}
