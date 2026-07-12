import 'dart:async';

import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBrewRepository implements BrewRepository {
  _FakeBrewRepository(this._results);

  final List<BrewDetection> _results;
  int detectCalls = 0;
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

    expect(find.text('Homebrew detected'), findsOneWidget);
  });

  testWidgets('shows Homebrew detected with version and path', (tester) async {
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

    expect(find.text('Homebrew detected'), findsOneWidget);
    expect(find.text('Version: Homebrew 6.0.9'), findsOneWidget);
    expect(find.text('Path: /opt/homebrew/bin/brew'), findsOneWidget);
    expect(find.text('Prefix: /opt/homebrew'), findsOneWidget);
  });

  testWidgets('shows not-found state', (tester) async {
    await tester.pumpWidget(
      BrewUiApp(brewRepository: _FakeBrewRepository([const BrewNotFound()])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Homebrew not found'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
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
    expect(find.text('Homebrew detected'), findsOneWidget);
  });
}
