import 'dart:io';

/// Runs an external command. Injectable for tests.
typedef BrewProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

/// Thin wrapper around process and filesystem I/O for Homebrew CLI access.
///
/// Holds no state and no resolution policy — repositories own that logic.
class BrewCliService {
  BrewCliService({
    BrewProcessRunner? run,
    Future<bool> Function(String path)? fileExists,
  }) : _run = run ?? Process.run,
       _fileExists = fileExists ?? ((path) async => File(path).exists());

  final BrewProcessRunner _run;
  final Future<bool> Function(String path) _fileExists;

  Future<ProcessResult> run(String executable, List<String> arguments) =>
      _run(executable, arguments);

  Future<bool> exists(String path) => _fileExists(path);
}
