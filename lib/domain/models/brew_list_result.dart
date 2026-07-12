/// Outcome of listing Homebrew formulae.
sealed class BrewListResult {
  const BrewListResult();
}

/// Formulae were listed successfully (empty list is valid).
final class BrewListSuccess extends BrewListResult {
  const BrewListSuccess(this.names);

  /// Formula names (one per entry) from list / outdated commands.
  final List<String> names;
}

/// Listing failed with a recoverable error.
final class BrewListError extends BrewListResult {
  const BrewListError(this.message);

  final String message;
}
