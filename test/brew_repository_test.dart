import 'dart:io';

import 'package:brewui/data/repositories/brew_repository_impl.dart';
import 'package:brewui/data/services/brew_cli_service.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';
import 'package:flutter_test/flutter_test.dart';

bool _argsEq(List<String> actual, List<String> expected) {
  if (actual.length != expected.length) return false;
  for (var i = 0; i < actual.length; i++) {
    if (actual[i] != expected[i]) return false;
  }
  return true;
}

void main() {
  group('BrewRepositoryImpl', () {
    test('returns BrewFound when brew --version succeeds', () async {
      final repository = BrewRepositoryImpl(
        cli: BrewCliService(
          run: (executable, args) async {
            if (executable == 'brew' && _argsEq(args, ['--version'])) {
              return ProcessResult(0, 0, 'Homebrew 6.0.9\n', '');
            }
            if (executable == 'brew' && _argsEq(args, ['--prefix'])) {
              return ProcessResult(0, 0, '/opt/homebrew\n', '');
            }
            if (executable == 'which' && _argsEq(args, ['brew'])) {
              return ProcessResult(0, 0, '/opt/homebrew/bin/brew\n', '');
            }
            fail('unexpected: $executable $args');
          },
        ),
        fallbackPaths: const [],
      );

      final result = await repository.detect();

      expect(
        result,
        isA<BrewFound>()
            .having((r) => r.version, 'version', 'Homebrew 6.0.9')
            .having(
              (r) => r.executablePath,
              'executablePath',
              '/opt/homebrew/bin/brew',
            )
            .having((r) => r.prefix, 'prefix', '/opt/homebrew'),
      );
    });

    test('returns BrewNotFound when no candidate works', () async {
      final repository = BrewRepositoryImpl(
        cli: BrewCliService(
          run: (executable, args) async {
            throw ProcessException(executable, args, 'not found', 2);
          },
          fileExists: (_) async => false,
        ),
        fallbackPaths: const ['/missing/brew'],
      );

      final result = await repository.detect();

      expect(result, isA<BrewNotFound>());
    });

    test('uses fallback path when PATH brew is missing', () async {
      final repository = BrewRepositoryImpl(
        cli: BrewCliService(
          run: (executable, args) async {
            if (executable == 'brew') {
              throw const ProcessException('brew', [], 'not found', 2);
            }
            if (executable == '/opt/homebrew/bin/brew' &&
                _argsEq(args, ['--version'])) {
              return ProcessResult(0, 0, 'Homebrew 6.0.9\n', '');
            }
            if (executable == '/opt/homebrew/bin/brew' &&
                _argsEq(args, ['--prefix'])) {
              return ProcessResult(0, 0, '/opt/homebrew\n', '');
            }
            fail('unexpected: $executable $args');
          },
          fileExists: (path) async => path == '/opt/homebrew/bin/brew',
        ),
        fallbackPaths: const ['/opt/homebrew/bin/brew'],
      );

      final result = await repository.detect();

      expect(
        result,
        isA<BrewFound>().having(
          (r) => r.executablePath,
          'executablePath',
          '/opt/homebrew/bin/brew',
        ),
      );
    });

    test('returns BrewDetectionError on non-zero version exit', () async {
      final repository = BrewRepositoryImpl(
        cli: BrewCliService(
          run: (executable, args) async {
            if (_argsEq(args, ['--version'])) {
              return ProcessResult(0, 1, '', 'permission denied\n');
            }
            fail('unexpected: $executable $args');
          },
        ),
        fallbackPaths: const [],
      );

      final result = await repository.detect();

      expect(
        result,
        isA<BrewDetectionError>().having(
          (r) => r.message,
          'message',
          'permission denied',
        ),
      );
    });

    test(
      'listInstalledFormulae returns names from brew list --formula',
      () async {
        final repository = BrewRepositoryImpl(
          cli: BrewCliService(
            run: (executable, args) async {
              expect(executable, '/opt/homebrew/bin/brew');
              expect(args, ['list', '--formula']);
              return ProcessResult(0, 0, 'git\nwget\n\ncurl\n', '');
            },
          ),
          fallbackPaths: const [],
        );

        final result = await repository.listInstalledFormulae(
          '/opt/homebrew/bin/brew',
        );

        expect(
          result,
          isA<BrewListSuccess>().having((r) => r.names, 'names', [
            'git',
            'wget',
            'curl',
          ]),
        );
      },
    );

    test('listInstalledFormulae allows empty list', () async {
      final repository = BrewRepositoryImpl(
        cli: BrewCliService(
          run: (executable, args) async {
            return ProcessResult(0, 0, '', '');
          },
        ),
        fallbackPaths: const [],
      );

      final result = await repository.listInstalledFormulae('brew');

      expect(
        result,
        isA<BrewListSuccess>().having((r) => r.names, 'names', isEmpty),
      );
    });

    test(
      'listInstalledFormulae returns BrewListError on non-zero exit',
      () async {
        final repository = BrewRepositoryImpl(
          cli: BrewCliService(
            run: (executable, args) async {
              return ProcessResult(0, 1, '', 'database locked\n');
            },
          ),
          fallbackPaths: const [],
        );

        final result = await repository.listInstalledFormulae('brew');

        expect(
          result,
          isA<BrewListError>().having(
            (r) => r.message,
            'message',
            'database locked',
          ),
        );
      },
    );
  });
}
