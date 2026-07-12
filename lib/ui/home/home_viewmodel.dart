import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/ui/core/command.dart';
import 'package:flutter/foundation.dart';

/// UI state and commands for the home (Homebrew detection) screen.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.brewRepository}) {
    detect = Command(_detect)..execute();
  }

  final BrewRepository brewRepository;

  /// Loads or refreshes Homebrew detection.
  late final Command detect;

  BrewDetection? _detection;
  BrewDetection? get detection => _detection;

  Future<void> _detect() async {
    _detection = null;
    notifyListeners();
    _detection = await brewRepository.detect();
    notifyListeners();
  }

  @override
  void dispose() {
    detect.dispose();
    super.dispose();
  }
}
