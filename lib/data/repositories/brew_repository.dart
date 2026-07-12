import 'package:brewui/domain/models/brew_detection.dart';

/// Source of truth for Homebrew-related application data.
abstract class BrewRepository {
  /// Resolves the brew executable and reports version / path or failure.
  Future<BrewDetection> detect();
}
