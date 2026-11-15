import 'package:flutter/material.dart';

/// Typography roles. Only family, size, weight, height and tracking live here —
/// colors come from the active theme so the same roles work in both modes.
///
/// Weights map to Inter as: H1 850, H2 700, Subtitle 600, Body 400,
/// Caption 500, Button 700. Flutter's [FontWeight] only exposes hundred steps,
/// so the H1 request of 850 rounds to the nearest supported step ([w900]).
abstract final class AppTypography {
  /// Bundled font family. When the Inter TTFs are absent the platform falls
  /// back to its default sans-serif, so text stays legible either way.
  static const String fontFamily = 'Inter';

  // Requested weights.
  static const FontWeight h1Weight = FontWeight.w900;
  static const FontWeight h2Weight = FontWeight.w700;
  static const FontWeight subtitleWeight = FontWeight.w600;
  static const FontWeight bodyWeight = FontWeight.w400;
  static const FontWeight captionWeight = FontWeight.w500;
  static const FontWeight buttonWeight = FontWeight.w700;

  /// Text scaling is clamped to this factor so layouts hold together.
  static const double maxTextScale = 1.3;

  // Role sizes.
  static const double h1FontSize = 34;
  static const double h2FontSize = 26;
  static const double h3FontSize = 22;
  static const double subtitleFontSize = 16;
  static const double bodyFontSize = 14;
  static const double captionFontSize = 12;
  static const double buttonFontSize = 16;
  static const double titleFontSize = 14;

  /// Onboarding hero sits between H2 and H3.
  static const double onboardingTitleSize = 30;

  // Role definitions. Widgets size containers from these rather than repeating
  // the numbers.
  static const TextStyle h1 = TextStyle(
    fontSize: h1FontSize,
    fontWeight: h1Weight,
    height: h1Height,
    letterSpacing: h1LetterSpacing,
  );
  static const double h1Height = 1.1;
  static const double h1LetterSpacing = -0.5;

  static const TextStyle h2 = TextStyle(
    fontSize: h2FontSize,
    fontWeight: h2Weight,
    height: h2Height,
    letterSpacing: h2LetterSpacing,
  );
  static const double h2Height = 1.15;
  static const double h2LetterSpacing = -0.3;

  static const TextStyle h3 = TextStyle(
    fontSize: h3FontSize,
    fontWeight: h2Weight,
    height: h3Height,
  );
  static const double h3Height = 1.2;

  static const TextStyle subtitle = TextStyle(
    fontSize: subtitleFontSize,
    fontWeight: subtitleWeight,
    height: subtitleHeight,
  );
  static const double subtitleHeight = 1.3;

  static const TextStyle body = TextStyle(
    fontSize: bodyFontSize,
    fontWeight: bodyWeight,
    height: bodyHeight,
  );
  static const double bodyHeight = 1.4;

  static const TextStyle caption = TextStyle(
    fontSize: captionFontSize,
    fontWeight: captionWeight,
    height: captionHeight,
  );
  static const double captionHeight = 1.35;

  static const TextStyle button = TextStyle(
    fontSize: buttonFontSize,
    fontWeight: buttonWeight,
    height: buttonHeight,
    letterSpacing: buttonLetterSpacing,
  );
  static const double buttonHeight = 1.2;
  static const double buttonLetterSpacing = 0.2;

  static const TextStyle titleLarge = TextStyle(
    fontSize: titleFontSize + 4,
    fontWeight: subtitleWeight,
    height: titleLargeHeight,
  );
  static const double titleLargeHeight = 1.25;

  static const TextStyle titleSmall = TextStyle(
    fontSize: titleFontSize,
    fontWeight: subtitleWeight,
    height: titleSmallHeight,
  );
  static const double titleSmallHeight = 1.35;

  static const TextStyle bodyLarge = TextStyle(
    fontSize: subtitleFontSize,
    fontWeight: bodyWeight,
    height: bodyLargeHeight,
  );
  static const double bodyLargeHeight = 1.45;

  static const TextStyle bodySmall = TextStyle(
    fontSize: captionFontSize,
    fontWeight: bodyWeight,
    height: bodySmallHeight,
  );
  static const double bodySmallHeight = 1.4;

  static const TextStyle labelMedium = TextStyle(
    fontSize: captionFontSize,
    fontWeight: subtitleWeight,
    height: labelMediumHeight,
    letterSpacing: labelMediumLetterSpacing,
  );
  static const double labelMediumHeight = 1.3;
  static const double labelMediumLetterSpacing = 0.1;

  /// RenderParagraph rounds line boxes up, so a measured line can be a fraction
  /// taller than `fontSize * height * scale`. Padding each measurement keeps
  /// fixed-height rows from clipping by a pixel.
  static const double lineHeightSlack = 1;

  /// Single-line box height a [style] needs at [scaler]'s scale factor.
  static double lineHeight(TextStyle style, TextScaler scaler) {
    final fontSize = style.fontSize ?? bodyFontSize;
    final height = style.height ?? bodyHeight;
    return scaler.scale(fontSize * height) + lineHeightSlack;
  }

  /// Builds the full [TextTheme]. Color slots are left to the caller to tint
  /// via `TextTheme.apply`.
  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,
      headlineLarge: h2,
      headlineMedium: h2,
      headlineSmall: h3,
      titleLarge: titleLarge,
      titleMedium: subtitle,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: button,
      labelMedium: labelMedium,
      labelSmall: caption,
    );
  }
}
