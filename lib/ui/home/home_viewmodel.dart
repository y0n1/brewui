import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';
import 'package:brewui/ui/core/command.dart';
import 'package:flutter/foundation.dart';

/// UI state and commands for the home screen.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.brewRepository}) {
    detect = Command(_detect);
    loadInstalled = Command(_loadInstalled);
    loadOutdated = Command(_loadOutdated);
    detect.execute();
  }

  final BrewRepository brewRepository;

  /// Loads or refreshes Homebrew detection (then lists when found).
  late final Command detect;

  /// Loads installed formulae when Homebrew is available.
  late final Command loadInstalled;

  /// Loads outdated formulae when Homebrew is available.
  late final Command loadOutdated;

  BrewDetection? _detection;
  BrewDetection? get detection => _detection;

  BrewListResult? _installed;
  BrewListResult? get installed => _installed;

  BrewListResult? _outdated;
  BrewListResult? get outdated => _outdated;

  Future<void> _detect() async {
    _detection = null;
    _installed = null;
    _outdated = null;
    notifyListeners();
    _detection = await brewRepository.detect();
    notifyListeners();
    if (_detection is BrewFound) {
      // Do not await — detect must finish so the found UI can show list loading.
      loadInstalled.execute();
      loadOutdated.execute();
    }
  }

  Future<void> _loadInstalled() async {
    final detection = _detection;
    if (detection is! BrewFound) return;

    _installed = null;
    notifyListeners();
    _installed = await brewRepository.listInstalledFormulae(
      detection.executablePath,
    );
    notifyListeners();
  }

  Future<void> _loadOutdated() async {
    final detection = _detection;
    if (detection is! BrewFound) return;

    _outdated = null;
    notifyListeners();
    _outdated = await brewRepository.listOutdatedFormulae(
      detection.executablePath,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    detect.dispose();
    loadInstalled.dispose();
    loadOutdated.dispose();
    super.dispose();
  }
}
