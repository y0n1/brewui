import 'dart:io';

import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';
import 'package:brewui/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens are macOS-only for now — pixel output differs on Linux CI hosts.
bool get _runGoldens => Platform.isMacOS;

class _FakeBrewRepository implements BrewRepository {
  _FakeBrewRepository(
    this.detection, {
    this.installed = const BrewListSuccess([]),
    this.outdated = const BrewListSuccess([]),
  });

  final BrewDetection detection;
  final BrewListResult installed;
  final BrewListResult outdated;

  @override
  Future<BrewDetection> detect() async => detection;

  @override
  Future<BrewListResult> listInstalledFormulae(String executable) async =>
      installed;

  @override
  Future<BrewListResult> listOutdatedFormulae(String executable) async =>
      outdated;
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required BrewDetection detection,
  BrewListResult installed = const BrewListSuccess([]),
  BrewListResult outdated = const BrewListSuccess([]),
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    BrewUiApp(
      brewRepository: _FakeBrewRepository(
        detection,
        installed: installed,
        outdated: outdated,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HomeScreen goldens', () {
    testWidgets('found with installed and outdated formulae', (tester) async {
      await _pumpHome(
        tester,
        detection: const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
          prefix: '/opt/homebrew',
        ),
        installed: const BrewListSuccess(['curl', 'git', 'wget']),
        outdated: const BrewListSuccess(['openssl@3']),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_found.png'),
      );
    }, skip: !_runGoldens);

    testWidgets('found with empty lists', (tester) async {
      await _pumpHome(
        tester,
        detection: const BrewFound(
          version: 'Homebrew 6.0.9',
          executablePath: '/opt/homebrew/bin/brew',
          prefix: '/opt/homebrew',
        ),
        installed: const BrewListSuccess([]),
        outdated: const BrewListSuccess([]),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_found_empty_list.png'),
      );
    }, skip: !_runGoldens);

    testWidgets('not found', (tester) async {
      await _pumpHome(tester, detection: const BrewNotFound());

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_not_found.png'),
      );
    }, skip: !_runGoldens);

    testWidgets('error', (tester) async {
      await _pumpHome(
        tester,
        detection: const BrewDetectionError('permission denied'),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_error.png'),
      );
    }, skip: !_runGoldens);
  });
}
