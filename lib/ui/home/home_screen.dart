import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Home screen: shows Homebrew detection found / not-found / error states.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('BrewUI')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable: viewModel.detect,
            builder: (context, child) {
              if (viewModel.detect.running) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Detecting Homebrew…'),
                  ],
                );
              }
              return child!;
            },
            child: _DetectionBody(viewModel: viewModel),
          ),
        ),
      ),
    );
  }
}

class _DetectionBody extends StatelessWidget {
  const _DetectionBody({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.detection) {
      BrewFound(:final version, :final executablePath, :final prefix) =>
        _FoundView(
          version: version,
          executablePath: executablePath,
          prefix: prefix,
          onRetry: viewModel.detect.execute,
        ),
      BrewNotFound() => _MessageView(
        title: 'Homebrew not found',
        body:
            'BrewUI could not find the brew executable on PATH or in the '
            'usual macOS install locations.',
        onRetry: viewModel.detect.execute,
      ),
      BrewDetectionError(:final message) => _MessageView(
        title: 'Could not detect Homebrew',
        body: message,
        onRetry: viewModel.detect.execute,
      ),
      null => const SizedBox.shrink(),
    };
  }
}

class _FoundView extends StatelessWidget {
  const _FoundView({
    required this.version,
    required this.executablePath,
    required this.prefix,
    required this.onRetry,
  });

  final String version;
  final String executablePath;
  final String? prefix;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Homebrew detected', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Version: $version'),
        Text('Path: $executablePath'),
        if (prefix != null) Text('Prefix: $prefix'),
        const SizedBox(height: 24),
        OutlinedButton(onPressed: onRetry, child: const Text('Refresh')),
      ],
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.title,
    required this.body,
    required this.onRetry,
  });

  final String title;
  final String body;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(body, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
