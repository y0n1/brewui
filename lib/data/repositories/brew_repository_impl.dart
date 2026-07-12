import 'dart:io';

import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/data/services/brew_cli_service.dart';
import 'package:brewui/domain/models/brew_detection.dart';

/// Detects whether Homebrew is available and reports version / path.
///
/// Resolution order:
/// 1. `brew` on the process PATH
/// 2. macOS Apple Silicon default: `/opt/homebrew/bin/brew`
/// 3. macOS Intel default: `/usr/local/bin/brew`
class BrewRepositoryImpl implements BrewRepository {
  BrewRepositoryImpl({required this.cli, List<String>? fallbackPaths})
    : _fallbackPaths =
          fallbackPaths ??
          const ['/opt/homebrew/bin/brew', '/usr/local/bin/brew'];

  final BrewCliService cli;
  final List<String> _fallbackPaths;

  @override
  Future<BrewDetection> detect() async {
    final candidates = <String>['brew', ..._fallbackPaths];

    Object? lastError;
    for (final candidate in candidates) {
      if (candidate != 'brew') {
        final exists = await cli.exists(candidate);
        if (!exists) continue;
      }

      try {
        final versionResult = await cli.run(candidate, ['--version']);
        if (versionResult.exitCode != 0) {
          lastError = _shortMessage(
            versionResult.stderr,
            fallback: 'brew --version failed (exit ${versionResult.exitCode})',
          );
          continue;
        }

        final version = _firstLine(versionResult.stdout);
        if (version.isEmpty) {
          lastError = 'brew --version returned empty output';
          continue;
        }

        String? prefix;
        try {
          final prefixResult = await cli.run(candidate, ['--prefix']);
          if (prefixResult.exitCode == 0) {
            final value = _firstLine(prefixResult.stdout);
            if (value.isNotEmpty) prefix = value;
          }
        } catch (_) {
          // Prefix is optional; version alone is enough for "found".
        }

        final executablePath = candidate == 'brew'
            ? await _resolveWhichBrew() ?? candidate
            : candidate;

        return BrewFound(
          version: version,
          executablePath: executablePath,
          prefix: prefix,
        );
      } on ProcessException catch (e) {
        // Missing executable on PATH — try next candidate.
        lastError = e.message;
        continue;
      } catch (e) {
        return BrewDetectionError(e.toString());
      }
    }

    if (lastError != null && !_looksLikeNotFound(lastError)) {
      return BrewDetectionError(lastError.toString());
    }
    return const BrewNotFound();
  }

  Future<String?> _resolveWhichBrew() async {
    try {
      final result = await cli.run('which', ['brew']);
      if (result.exitCode == 0) {
        final path = _firstLine(result.stdout);
        if (path.isNotEmpty) return path;
      }
    } catch (_) {
      // Optional; fall back to the bare `brew` token.
    }
    return null;
  }

  static String _firstLine(Object? output) {
    final text = output?.toString() ?? '';
    final line = text
        .split('\n')
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    return line.trim();
  }

  static String _shortMessage(Object? stderr, {required String fallback}) {
    final text = stderr?.toString().trim() ?? '';
    if (text.isEmpty) return fallback;
    final line = text.split('\n').first.trim();
    return line.isEmpty ? fallback : line;
  }

  static bool _looksLikeNotFound(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('not found') ||
        text.contains('no such file') ||
        text.contains('cannot find');
  }
}
