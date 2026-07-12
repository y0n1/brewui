import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';
import 'package:brewui/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Home screen: Homebrew detection plus read-only installed formulae.
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
          viewModel: viewModel,
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
    required this.viewModel,
  });

  final String version;
  final String executablePath;
  final String? prefix;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 520),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Homebrew detected', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('Version: $version'),
          Text('Path: $executablePath'),
          if (prefix != null) Text('Prefix: $prefix'),
          const SizedBox(height: 24),
          Text('Installed formulae', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListenableBuilder(
              listenable: viewModel.loadInstalled,
              builder: (context, _) => _InstalledSection(viewModel: viewModel),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: viewModel.detect.execute,
              child: const Text('Refresh'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstalledSection extends StatelessWidget {
  const _InstalledSection({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.loadInstalled.running) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading installed formulae…'),
          ],
        ),
      );
    }

    return switch (viewModel.installed) {
      BrewListSuccess(:final names) when names.isEmpty => const Center(
        child: Text('No formulae installed.'),
      ),
      BrewListSuccess(:final names) => ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(names[index]),
          );
        },
      ),
      BrewListError(:final message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: viewModel.loadInstalled.execute,
              child: const Text('Retry list'),
            ),
          ],
        ),
      ),
      null => const SizedBox.shrink(),
    };
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
