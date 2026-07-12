/// Outcome of detecting the Homebrew (`brew`) executable.
sealed class BrewDetection {
  const BrewDetection();
}

/// Homebrew was found and responded successfully.
final class BrewFound extends BrewDetection {
  const BrewFound({
    required this.version,
    required this.executablePath,
    this.prefix,
  });

  /// First line of `brew --version` (e.g. `Homebrew 6.0.9`).
  final String version;

  /// Resolved path to the `brew` executable used for detection.
  final String executablePath;

  /// Output of `brew --prefix`, when obtainable.
  final String? prefix;
}

/// No `brew` executable was found on PATH or known fallback locations.
final class BrewNotFound extends BrewDetection {
  const BrewNotFound();
}

/// `brew` was found (or attempted) but detection failed for another reason.
final class BrewDetectionError extends BrewDetection {
  const BrewDetectionError(this.message);

  final String message;
}
