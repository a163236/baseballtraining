import 'package:flutter/material.dart';

import 'screens/title_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BaseballTrainingApp());
}

class BaseballTrainingApp extends StatelessWidget {
  const BaseballTrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '野球部監督',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const TitleScreen(),
    );
  }
}
