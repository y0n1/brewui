import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';
import 'package:brewui/ui/core/command.dart';
import 'package:brewui/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Home screen: Homebrew detection plus read-only installed / outdated lists.
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
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
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
              builder: (context, _) => _FormulaListSection(
                command: viewModel.loadInstalled,
                result: viewModel.installed,
                loadingLabel: 'Loading installed formulae…',
                emptyLabel: 'No formulae installed.',
                onRetry: viewModel.loadInstalled.execute,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Outdated formulae', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListenableBuilder(
              listenable: viewModel.loadOutdated,
              builder: (context, _) => _FormulaListSection(
                command: viewModel.loadOutdated,
                result: viewModel.outdated,
                loadingLabel: 'Loading outdated formulae…',
                emptyLabel: 'No outdated formulae.',
                onRetry: viewModel.loadOutdated.execute,
              ),
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

class _FormulaListSection extends StatelessWidget {
  const _FormulaListSection({
    required this.command,
    required this.result,
    required this.loadingLabel,
    required this.emptyLabel,
    required this.onRetry,
  });

  final Command command;
  final BrewListResult? result;
  final String loadingLabel;
  final String emptyLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (command.running) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(loadingLabel),
          ],
        ),
      );
    }

    return switch (result) {
      BrewListSuccess(:final names) when names.isEmpty => Center(
        child: Text(emptyLabel),
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
            OutlinedButton(onPressed: onRetry, child: const Text('Retry list')),
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
