import 'package:flutter/material.dart';
import 'theme/brutalist_theme.dart';
import 'screens/main_shell.dart';
import 'screens/auth/sign_in_screen.dart';

void main() {
  runApp(const PromptLibApp());
}

class PromptLibApp extends StatelessWidget {
  const PromptLibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PromptLib',
      debugShowCheckedModeBanner: false,
      theme: BrutalistTheme.lightTheme,
      // For now we start at MainShell, later we can add Auth routing logic
      home: const MainShell(),
    );
  }
}
