import 'package:flutter/material.dart';

void main() {
  runApp(const BrewUiApp());
}

class BrewUiApp extends StatelessWidget {
  const BrewUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrewUI',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('BrewUI'),
        ),
      ),
    );
  }
}
