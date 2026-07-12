import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';

/// Source of truth for Homebrew-related application data.
abstract class BrewRepository {
  /// Resolves the brew executable and reports version / path or failure.
  Future<BrewDetection> detect();

  /// Lists installed formulae via `brew list --formula` using [executable].
  Future<BrewListResult> listInstalledFormulae(String executable);

  /// Lists outdated formulae via `brew outdated --formula` using [executable].
  Future<BrewListResult> listOutdatedFormulae(String executable);
}
