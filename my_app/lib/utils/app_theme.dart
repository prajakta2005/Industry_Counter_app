import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTheme {
  AppTheme._();


  static const Color primary       = Color(0xFF1A1F36);
  static const Color accent        = Color(0xFF00C896);
  static const Color accentDark    = Color(0xFF00A87E);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color background    = Color(0xFFF5F6FA);
  static const Color border        = Color(0xFFE2E4ED);
  static const Color textPrimary   = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFFB0B7C3);
  static const Color success       = Color(0xFF00C896);
  static const Color error         = Color(0xFFEF4444);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color info          = Color(0xFF3B82F6);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF0F1120);
  static const Color darkSurface    = Color(0xFF1A1F36);
  static const Color darkCard       = Color(0xFF252B45);
  static const Color darkBorder     = Color(0xFF2E3553);


  static const double spaceXS      = 4.0;
  static const double spaceSM      = 8.0;
  static const double spaceMD      = 16.0;
  static const double spaceLG      = 24.0;
  static const double spaceXL      = 32.0;
  static const double spaceXXL     = 48.0;
  static const double screenPadding = 20.0;


  static const double radiusSM   = 8.0;
  static const double radiusMD   = 12.0;
  static const double radiusLG   = 16.0;
  static const double radiusXL   = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadiusSM   = BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD   = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG   = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL   = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));


  static TextTheme get textTheme => GoogleFonts.interTextTheme(
    const TextTheme(
      // Screen titles
      displayLarge: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: textPrimary, letterSpacing: -0.5,
      ),
      // Section headings
      displayMedium: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: textPrimary, letterSpacing: -0.3,
      ),
      // Card titles, dialog headings
      displaySmall: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // The BIG count number — "847" after counting
      headlineLarge: TextStyle(
        fontSize: 72, fontWeight: FontWeight.w800,
        color: textPrimary, letterSpacing: -2,
      ),
      // Sub-count label — "items detected"
      headlineMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      // List tile titles
      titleLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      // List tile subtitles
      titleMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      // Badges, chips, small labels
      titleSmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: textSecondary, letterSpacing: 0.2,
      ),
      // Regular body text
      bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: textPrimary, height: 1.5,
      ),
      // Secondary body — descriptions, helper text
      bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: textSecondary, height: 1.5,
      ),
      // Captions, timestamps
      bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: textHint,
      ),
      // Button labels
      labelLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary:          primary,
      onPrimary:        Colors.white,
      secondary:        accent,
      onSecondary:      Colors.white,
      surface:          surface,
      onSurface:        textPrimary,
      error:            error,
      onError:          Colors.white,
      outline:          border,
      surfaceVariant:   background,
      onSurfaceVariant: textSecondary,
    );

    return ThemeData(
      useMaterial3:           true,
      colorScheme:            colorScheme,
      textTheme:              textTheme,
      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor:          surface,
        foregroundColor:          textPrimary,
        elevation:                0,
        scrolledUnderElevation:   1,
        shadowColor:              border,
        centerTitle:              false,
        titleTextStyle:           textTheme.displaySmall,
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),

      // Cards
      cardTheme: CardThemeData(
        color:     surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusLG,
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Primary filled button — main CTA ("Save Log", "Count")
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F6E56),
          foregroundColor: Colors.white,
          minimumSize:     const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(borderRadius: borderRadiusMD),
          elevation:       0,
          textStyle:       textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLG,
            vertical:   spaceMD,
          ),
        ),
      ),

      // Accent filled button — "Export", "Count Now"
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize:     const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(borderRadius: borderRadiusMD),
          elevation:       0,
          textStyle:       textTheme.labelLarge,
        ),
      ),

      // Outlined button — secondary actions
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize:     const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(borderRadius: borderRadiusMD),
          side: const BorderSide(color: border, width: 1.5),
          textStyle:       textTheme.labelLarge,
        ),
      ),

      // Text button — low emphasis
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textSecondary,
          textStyle:       textTheme.labelMedium,
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: textHint),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMD,
          vertical:   spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadiusMD,
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMD,
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMD,
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMD,
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMD,
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),

      // Bottom nav bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     surface,
        selectedItemColor:   accent,
        unselectedItemColor: textHint,
        elevation:           0,
        type: BottomNavigationBarType.fixed,
      ),

      // Chips — material type tags
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor:   accent,
        labelStyle:      textTheme.labelSmall,
        side: const BorderSide(color: border),
        shape: const RoundedRectangleBorder(borderRadius: borderRadiusFull),
        padding: const EdgeInsets.symmetric(
          horizontal: spaceMD,
          vertical:   spaceXS,
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color:     border,
        thickness: 1,
        space:     1,
      ),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor:  primary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: borderRadiusMD),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary:          accent,
      onPrimary:        darkBackground,
      secondary:        accent,
      onSecondary:      darkBackground,
      surface:          darkSurface,
      onSurface:        Colors.white,
      error:            error,
      onError:          Colors.white,
      outline:          darkBorder,
      surfaceVariant:   darkCard,
      onSurfaceVariant: Colors.white,
    );

    return ThemeData(
      useMaterial3:            true,
      colorScheme:             colorScheme,
      textTheme:               textTheme.apply(
        bodyColor:    Colors.white,
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation:       0,
        titleTextStyle:  textTheme.displaySmall?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      cardTheme: CardThemeData(
        color:     darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusLG,
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: darkBackground,
          minimumSize:     const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(borderRadius: borderRadiusMD),
          elevation:       0,
          textStyle:       textTheme.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: darkCard,
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white38),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMD,
          vertical:   spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadiusMD,
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMD,
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMD,
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color:     darkBorder,
        thickness: 1,
        space:     1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:  darkCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: borderRadiusMD),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}