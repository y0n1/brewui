import 'package:flutter/foundation.dart';

/// Encapsulates an async action with running / completed / error state.
///
/// Views call [execute]; ViewModels own Command instances as members.
/// See https://docs.flutter.dev/app-architecture/design-patterns/command
class Command extends ChangeNotifier {
  Command(this._action);

  final Future<void> Function() _action;

  bool _running = false;
  bool get running => _running;

  Exception? _error;
  Exception? get error => _error;

  bool _completed = false;
  bool get completed => _completed;

  Future<void> execute() async {
    if (_running) return;

    _running = true;
    _completed = false;
    _error = null;
    notifyListeners();

    try {
      await _action();
      _completed = true;
    } on Exception catch (error) {
      _error = error;
    } finally {
      _running = false;
      notifyListeners();
    }
  }

  void clear() {
    _running = false;
    _error = null;
    _completed = false;
  }
}
