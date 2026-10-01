import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Material 3 Dark Color Scheme (Red Seed)
  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFB4AB),
    onPrimary: Color(0xFF690005),
    primaryContainer: Color(0xFF93000A),
    onPrimaryContainer: Color(0xFFFFDAD6),
    secondary: Color(0xFFE7BDB8),
    onSecondary: Color(0xFF442926),
    secondaryContainer: Color(0xFF5D3F3B),
    onSecondaryContainer: Color(0xFFFFDAD6),
    tertiary: Color(0xFFE0C38C),
    onTertiary: Color(0xFF3F2E04),
    tertiaryContainer: Color(0xFF584419),
    onTertiaryContainer: Color(0xFFFDE0A6),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE3E3E3),
    surfaceContainerHighest: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFFC4C7C5),
    outline: Color(0xFF8E918F),
    outlineVariant: Color(0xFF444746),
    inverseSurface: Color(0xFFE3E3E3),
    onInverseSurface: Color(0xFF121212),
    inversePrimary: Color(0xFFC00010),
    shadow: Colors.black,
    scrim: Colors.black,
  );

  // Material 3 Light Color Scheme (Red Seed)
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFC00010),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFDAD6),
    onPrimaryContainer: Color(0xFF410002),
    secondary: Color(0xFF775652),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFDAD6),
    onSecondaryContainer: Color(0xFF2C1512),
    tertiary: Color(0xFF715B2E),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFDE0A6),
    onTertiaryContainer: Color(0xFF261900),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF8F9FA),
    onSurface: Color(0xFF1F1F1F),
    surfaceContainerHighest: Color(0xFFE9ECEF),
    onSurfaceVariant: Color(0xFF495057),
    outline: Color(0xFFADB5BD),
    outlineVariant: Color(0xFFDEE2E6),
    inverseSurface: Color(0xFF212529),
    onInverseSurface: Color(0xFFF8F9FA),
    inversePrimary: Color(0xFFFFB4AB),
    shadow: Colors.black,
    scrim: Colors.black,
  );

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0),
      displaySmall: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0),
      headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0),
      headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0),
      headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0),
      titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: darkColorScheme.surface,
      cardColor: darkColorScheme.surfaceContainerHighest,
      cardTheme: CardThemeData(
        color: darkColorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkColorScheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: darkColorScheme.outlineVariant,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: lightColorScheme.surface,
      cardColor: lightColorScheme.surfaceContainerHighest,
      cardTheme: CardThemeData(
        color: lightColorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: lightColorScheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: lightColorScheme.outlineVariant,
    );
  }
}
