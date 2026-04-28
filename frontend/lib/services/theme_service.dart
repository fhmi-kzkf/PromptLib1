import 'package:flutter/material.dart';
import '../theme/brutalist_theme.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<Color> accentColor = ValueNotifier<Color>(BrutalistColors.primary);

  void updateAccentColor(Color newColor) {
    accentColor.value = newColor;
  }

  Color get currentAccentColor => accentColor.value;
}
