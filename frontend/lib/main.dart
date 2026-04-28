import 'package:flutter/material.dart';
import 'theme/brutalist_theme.dart';
import 'screens/main_shell.dart';
import 'screens/auth/sign_in_screen.dart';
import 'services/theme_service.dart';


void main() {
  runApp(const PromptLibApp());
}

class PromptLibApp extends StatelessWidget {
  const PromptLibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService().accentColor,
      builder: (context, accentColor, _) {
        return MaterialApp(
          title: 'PromptLib',
          debugShowCheckedModeBanner: false,
          theme: BrutalistTheme.getDynamicTheme(accentColor),
          // Start at login screen — user must authenticate first
          home: const SignInScreen(),
        );
      },
    );
  }
}

