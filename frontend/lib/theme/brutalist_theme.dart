import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrutalistColors {
  static const primary = Color(0xFFFFD700); // Cyber Yellow
  static const secondary = Color(0xFF4ECDC4); // Electric Cyan
  static const tertiary = Color(0xFFFF6B6B); // Vivid Pink
  static const background = Color(0xFFF9F9F9); // Off-White
  static const concrete = Color(0xFFEEEEEE);
  static const black = Colors.black;
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
      bodyLarge: GoogleFonts.inter(
        color: BrutalistColors.black,
      ),
      bodyMedium: GoogleFonts.inter(
        color: BrutalistColors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: BrutalistColors.primary,
      primary: BrutalistColors.primary,
      secondary: BrutalistColors.secondary,
      tertiary: BrutalistColors.tertiary,
      background: BrutalistColors.background,
    ),
  );

  static const double borderWidth = 4.0;
  static const double shadowOffset = 6.0;

  static BoxDecoration getNakedDecoration({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: BrutalistColors.black, width: borderWidth),
    );
  }

  static BoxDecoration getShadowDecoration({Color color = Colors.white, double offset = shadowOffset}) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: BrutalistColors.black, width: borderWidth),
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
