import 'package:flutter/material.dart';

import 'amp_colors.dart';

/// Amperly's Material 3 theme, overridden aggressively on purpose.
///
/// No seed colour, no default purple, no surface-tint wash, no elevation
/// overlay. Separation comes from the paper surface, hairlines and spacing.
abstract final class AmpTheme {
  static const String uiFont = 'PlusJakartaSans';
  static const String displayFont = 'Fraunces';

  /// 4-40 spacing scale; one source for layouts and widgets.
  static const double spaceXs = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 40;
  static const double screenPadding = 20;

  static const double radiusCard = 14;
  static const double radiusField = 8;
  static const double radiusPill = 999;
  static const double touchTarget = 48;

  static ThemeData light() => _build(Brightness.light, AmpColors.light);

  static ThemeData dark() => _build(Brightness.dark, AmpColors.dark);

  static ThemeData _build(Brightness brightness, AmpColors c) {
    final TextTheme text = _textTheme(c);
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryTint,
      onPrimaryContainer: c.onPrimaryTint,
      secondary: c.info,
      onSecondary: brightness == Brightness.light ? Colors.white : c.background,
      secondaryContainer: c.infoTint,
      onSecondaryContainer: c.info,
      tertiary: c.energy,
      onTertiary: c.onEnergy,
      tertiaryContainer: c.energyTint,
      onTertiaryContainer: c.busyInk,
      error: c.error,
      onError: c.onError,
      errorContainer: c.errorTint,
      onErrorContainer: c.error,
      surface: c.surface,
      onSurface: c.ink,
      surfaceContainerLowest: c.surface,
      surfaceContainerLow: c.background,
      surfaceContainer: c.surfaceVariant,
      surfaceContainerHigh: c.surfaceVariant,
      surfaceContainerHighest: c.surfaceVariant,
      onSurfaceVariant: c.inkSecondary,
      outline: c.outline,
      outlineVariant: c.divider,
      inverseSurface: c.inverseSurface,
      onInverseSurface: c.onInverseSurface,
      inversePrimary: c.primaryTint,
      surfaceTint: Colors.transparent,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      fontFamily: uiFont,
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[c],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: c.ink.withValues(alpha: 0.06),
      hoverColor: c.ink.withValues(alpha: 0.04),
      focusColor: c.ink.withValues(alpha: 0.06),
      dividerColor: c.divider,
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: c.ink, size: 20),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
        toolbarHeight: 64,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: c.divider),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, touchTarget),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusField),
          ),
          textStyle: const TextStyle(
            fontFamily: uiFont,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(64, touchTarget),
          side: BorderSide(color: c.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusField),
          ),
          textStyle: const TextStyle(
            fontFamily: uiFont,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(48, touchTarget),
          textStyle: const TextStyle(
            fontFamily: uiFont,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: text.bodyLarge?.copyWith(color: c.inkSecondary),
        labelStyle: text.bodyLarge?.copyWith(color: c.inkSecondary),
        errorStyle: text.bodySmall?.copyWith(color: c.error),
        helperStyle: text.bodySmall,
        prefixIconColor: c.inkSecondary,
        suffixIconColor: c.inkSecondary,
        border: _border(c.divider),
        enabledBorder: _border(c.divider),
        focusedBorder: _border(c.primary, width: 1.5),
        errorBorder: _border(c.error),
        focusedErrorBorder: _border(c.error, width: 1.5),
        disabledBorder: _border(c.divider.withValues(alpha: 0.5)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: const Color.fromRGBO(0, 0, 0, 0.42),
        elevation: 0,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.onInverseSurface),
        actionTextColor: c.onInverseSurface,
        elevation: 2,
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusField),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primaryTint,
        selectionHandleColor: c.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.surfaceVariant,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: text.bodySmall?.copyWith(color: c.onInverseSurface),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusField),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(AmpColors c) {
    const List<FontFeature> tabular = <FontFeature>[
      FontFeature.tabularFigures(),
    ];
    return TextTheme(
      // Fraunces is the personality: large numbers and a few headlines only.
      displayLarge: TextStyle(
        fontFamily: displayFont,
        fontSize: 32,
        height: 1.13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: c.ink,
        fontFeatures: tabular,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFont,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: c.ink,
        fontFeatures: tabular,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFont,
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: c.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: uiFont,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: c.ink,
      ),
      headlineSmall: TextStyle(
        fontFamily: uiFont,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: c.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: uiFont,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: c.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: uiFont,
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: c.ink,
      ),
      titleSmall: TextStyle(
        fontFamily: uiFont,
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: c.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: uiFont,
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: c.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: uiFont,
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: c.ink,
      ),
      bodySmall: TextStyle(
        fontFamily: uiFont,
        fontSize: 13,
        height: 1.45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: c.inkSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: uiFont,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: c.inkSecondary,
      ),
      labelMedium: TextStyle(
        fontFamily: uiFont,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: c.inkSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: uiFont,
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: c.inkSecondary,
      ),
    );
  }
}

/// Type helpers that are not part of Material's named scale.
abstract final class AmpType {
  /// A number the screen is built around. Fraunces, tabular, never jitters.
  static TextStyle metric(
    BuildContext context, {
    double size = 32,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AmpTheme.displayFont,
      fontSize: size,
      height: 1.08,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.8,
      color: color ?? context.amp.ink,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
  }

  /// The small, spaced label above a section. The only uppercase text.
  static TextStyle eyebrow(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: AmpTheme.uiFont,
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: color ?? context.amp.inkSecondary,
    );
  }

  /// Any other number (prices, kWh, times) in tabular figures.
  static TextStyle tabular(TextStyle base) {
    return base.copyWith(
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
  }
}
