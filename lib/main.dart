import 'package:brewui/data/repositories/brew_repository.dart';
import 'package:brewui/data/repositories/brew_repository_impl.dart';
import 'package:brewui/data/services/brew_cli_service.dart';
import 'package:brewui/ui/home/home_screen.dart';
import 'package:brewui/ui/home/home_viewmodel.dart';
import 'package:brewui/ui/theme/brew_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const BrewUiApp());
}

class BrewUiApp extends StatelessWidget {
  const BrewUiApp({super.key, this.brewRepository});

  /// Optional override for tests.
  final BrewRepository? brewRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (brewRepository == null) ...[
          Provider(create: (_) => BrewCliService()),
          Provider<BrewRepository>(
            create: (context) =>
                BrewRepositoryImpl(cli: context.read<BrewCliService>()),
          ),
        ] else
          Provider<BrewRepository>.value(value: brewRepository!),
        ChangeNotifierProvider(
          create: (context) =>
              HomeViewModel(brewRepository: context.read<BrewRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'BrewUI',
        theme: buildBrewTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
