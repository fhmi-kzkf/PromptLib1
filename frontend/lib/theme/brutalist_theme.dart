import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrutalistColors {
  static const primary = Color(0xFF496400); 
  static const primaryContainer = Color(0xFFBEFC00);
  static const onPrimary = Color(0xFFDEFF95);
  static const secondary = Color(0xFF0846ED);
  static const background = Color(0xFFF6F6F6);
  static const surface = Color(0xFFF6F6F6);
  static const black = Color(0xFF0E0E0E);
  static const surfaceVariant = Color(0xFFDDDDDD);
  static const outline = Color(0xFF777777);
  static const outlineVariant = Color(0xFFADADAD);
  static const concrete = Color(0xFFEEEEEE);
  static const error = Color(0xFFB02500);
}

class BrutalistTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: BrutalistColors.primary,
    scaffoldBackgroundColor: BrutalistColors.background,
    textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w900,
        color: BrutalistColors.black,
        letterSpacing: -2,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w800,
        color: BrutalistColors.black,
        letterSpacing: -1,
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        color: BrutalistColors.black,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        color: BrutalistColors.black,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: BrutalistColors.primary,
      onPrimary: BrutalistColors.onPrimary,
      primaryContainer: BrutalistColors.primaryContainer,
      secondary: BrutalistColors.secondary,
      background: BrutalistColors.background,
      error: BrutalistColors.error,
      surface: BrutalistColors.surface,
      onSurface: BrutalistColors.black,
    ),
  );

  static ThemeData getDynamicTheme(Color primaryColor) {
    return lightTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: primaryColor,
      ),
    );
  }

  static const double borderWidth = 3.0;
  static const double shadowOffset = 8.0;
  static const double shadowOffsetSm = 4.0;

  static BoxDecoration getNakedDecoration({
    Color color = Colors.white,
    double bWidth = borderWidth,
  }) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: BrutalistColors.black, width: bWidth),
    );
  }

  static BoxDecoration getShadowDecoration({
    Color color = Colors.white,
    double offset = shadowOffset,
    double bWidth = borderWidth,
  }) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: BrutalistColors.black, width: bWidth),
      boxShadow: [
        BoxShadow(
          color: BrutalistColors.black,
          offset: Offset(offset, offset),
          blurRadius: 0,
        ),
      ],
    );
  }
}
