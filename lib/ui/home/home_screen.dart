import 'package:brewui/domain/models/brew_detection.dart';
import 'package:brewui/domain/models/brew_list_result.dart';
import 'package:brewui/ui/core/command.dart';
import 'package:brewui/ui/home/home_viewmodel.dart';
import 'package:brewui/ui/theme/brew_colors.dart';
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
      body: ListenableBuilder(
        listenable: viewModel.detect,
        builder: (context, _) {
          if (viewModel.detect.running && viewModel.detection == null) {
            return const _DetectingView();
          }
          return _DetectionBody(viewModel: viewModel);
        },
      ),
    );
  }
}

class _DetectingView extends StatelessWidget {
  const _DetectingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Detecting Homebrew…'),
        ],
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
          refreshing: viewModel.detect.running,
        ),
      BrewNotFound() => _MessageView(
        icon: Icons.warning_rounded,
        iconColor: BrewColors.marigold,
        title: 'Homebrew not found',
        body:
            'BrewUI could not find a Homebrew installation on this Mac.\n'
            'Install Homebrew, then tap Retry.',
        onRetry: viewModel.detect.execute,
      ),
      BrewDetectionError(:final message) => _MessageView(
        icon: Icons.cancel_rounded,
        iconColor: BrewColors.danger,
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
    required this.refreshing,
  });

  final String version;
  final String executablePath;
  final String? prefix;
  final HomeViewModel viewModel;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusStrip(
            version: version,
            executablePath: executablePath,
            prefix: prefix,
            refreshing: refreshing,
            onRefresh: viewModel.detect.execute,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: viewModel.loadInstalled,
                    builder: (context, _) => _FormulaListPanel(
                      title: 'Installed formulae',
                      command: viewModel.loadInstalled,
                      result: viewModel.installed,
                      loadingLabel: 'Loading…',
                      emptyLabel: 'No formulae installed.',
                      onRetry: viewModel.loadInstalled.execute,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListenableBuilder(
                    listenable: viewModel.loadOutdated,
                    builder: (context, _) => _FormulaListPanel(
                      title: 'Outdated formulae',
                      command: viewModel.loadOutdated,
                      result: viewModel.outdated,
                      loadingLabel: 'Loading…',
                      emptyLabel: 'No outdated formulae.',
                      onRetry: viewModel.loadOutdated.execute,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.version,
    required this.executablePath,
    required this.prefix,
    required this.refreshing,
    required this.onRefresh,
  });

  final String version;
  final String executablePath;
  final String? prefix;
  final bool refreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final pathLine = prefix == null
        ? executablePath
        : '$executablePath  ·  prefix $prefix';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrewColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: BrewColors.success, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(version, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(pathLine, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (refreshing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              OutlinedButton(
                onPressed: onRefresh,
                child: const Text('Refresh'),
              ),
          ],
        ),
      ),
    );
  }
}

class _FormulaListPanel extends StatelessWidget {
  const _FormulaListPanel({
    required this.title,
    required this.command,
    required this.result,
    required this.loadingLabel,
    required this.emptyLabel,
    required this.onRetry,
  });

  final String title;
  final Command command;
  final BrewListResult? result;
  final String loadingLabel;
  final String emptyLabel;
  final VoidCallback onRetry;

  int? get _count => switch (result) {
    BrewListSuccess(:final names) when !command.running => names.length,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrewColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BrewColors.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_count != null) _CountChip(count: _count!),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (command.running) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(loadingLabel, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return switch (result) {
      BrewListSuccess(:final names) when names.isEmpty => Center(
        child: Text(emptyLabel, style: Theme.of(context).textTheme.bodySmall),
      ),
      BrewListSuccess(:final names) => ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(names[index]));
        },
      ),
      BrewListError(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry list'),
              ),
            ],
          ),
        ),
      ),
      null => const SizedBox.shrink(),
    };
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrewColors.dallas,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          '$count',
          style: const TextStyle(
            color: BrewColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.onRetry,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
