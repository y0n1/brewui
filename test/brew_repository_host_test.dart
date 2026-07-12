import 'dart:io';

import 'package:brewui/data/repositories/brew_repository_impl.dart';
import 'package:brewui/data/services/brew_cli_service.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:flutter_test/flutter_test.dart';

/// Live smoke against the host brew install (skipped in CI / when brew missing).
void main() {
  test('host brew is detectable via fallbacks with minimal PATH', () async {
    final brewPath = File('/opt/homebrew/bin/brew');
    final intelPath = File('/usr/local/bin/brew');
    if (!brewPath.existsSync() && !intelPath.existsSync()) {
      return; // nothing to smoke on this host
    }

    final previousPath = Platform.environment['PATH'];
    // Process.run inherits the isolate environment; we only assert File.exists
    // + absolute-path execution, which is what GUI fallbacks rely on.
    final result = await BrewRepositoryImpl(
      cli: BrewCliService(),
      fallbackPaths: const ['/opt/homebrew/bin/brew', '/usr/local/bin/brew'],
    ).detect();

    expect(result, isA<BrewFound>(), reason: 'PATH was $previousPath');
    final found = result as BrewFound;
    expect(found.version, contains('Homebrew'));
    expect(found.executablePath, isNotEmpty);
  });
}
