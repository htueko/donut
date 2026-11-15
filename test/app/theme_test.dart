import 'package:donut/app/theme/app_colors.dart';
import 'package:donut/app/theme/app_palette.dart';
import 'package:donut/app/theme/app_theme.dart';
import 'package:donut/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Relative luminance per WCAG 2.x.
double _luminance(Color color) => color.computeLuminance();

/// WCAG contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  final lighter = _luminance(a) > _luminance(b) ? a : b;
  final darker = _luminance(a) > _luminance(b) ? b : a;
  return (_luminance(lighter) + 0.05) / (_luminance(darker) + 0.05);
}

void main() {
  group('palette', () {
    test('light and dark expose different backgrounds and surfaces', () {
      expect(AppPalette.light.background, isNot(AppPalette.dark.background));
      expect(AppPalette.light.surface, isNot(AppPalette.dark.surface));
      expect(AppPalette.light.textPrimary, isNot(AppPalette.dark.textPrimary));
      expect(AppPalette.light.border, isNot(AppPalette.dark.border));
    });

    test('dark background is genuinely dark and light is genuinely light', () {
      expect(_luminance(AppPalette.dark.background), lessThan(0.1));
      expect(_luminance(AppPalette.light.background), greaterThan(0.8));
    });

    test('brand colors match the design tokens', () {
      expect(AppColors.primaryCyan, const Color(0xFF4EC5E6));
      expect(AppColors.primaryPink, const Color(0xFFFF5398));
      expect(AppColors.accentOrange, const Color(0xFFFF7E27));
      expect(AppColors.tierSilver, const Color(0xFFB5B8BD));
      expect(AppColors.tierGold, const Color(0xFFE5C158));
      expect(AppColors.tierPlatinum, const Color(0xFF7AD7F0));
    });

    test('body text clears 4.5:1 against its background in both modes', () {
      for (final palette in [AppPalette.light, AppPalette.dark]) {
        expect(
          _contrast(palette.textPrimary, palette.background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(palette.textSecondary, palette.background),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('primary label clears 3:1 against the primary fill', () {
      for (final palette in [AppPalette.light, AppPalette.dark]) {
        expect(
          _contrast(palette.onPrimary, palette.primary),
          greaterThanOrEqualTo(3),
        );
      }
    });
  });

  group('themes', () {
    test('light theme uses the light palette', () {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppPalette.light.background);
      expect(
        theme.extension<AppPalette>()?.background,
        AppPalette.light.background,
      );
    });

    test('dark theme uses the dark palette', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppPalette.dark.background);
      expect(
        theme.extension<AppPalette>()?.background,
        AppPalette.dark.background,
      );
    });

    test('color scheme is derived from the palette, not from a seed guess', () {
      expect(AppTheme.light.colorScheme.primary, AppPalette.light.primary);
      expect(AppTheme.dark.colorScheme.primary, AppPalette.dark.primary);
      expect(AppTheme.light.colorScheme.secondary, AppPalette.light.secondary);
      expect(AppTheme.dark.colorScheme.secondary, AppPalette.dark.secondary);
    });
  });

  group('typography', () {
    test('H1 and H2 use the requested Inter weights', () {
      expect(AppTypography.h1.fontWeight, AppTypography.h1Weight);
      expect(AppTypography.h2.fontWeight, AppTypography.h2Weight);
      expect(AppTypography.subtitle.fontWeight, FontWeight.w600);
      expect(AppTypography.body.fontWeight, FontWeight.w400);
      expect(AppTypography.caption.fontWeight, FontWeight.w500);
      expect(AppTypography.button.fontWeight, FontWeight.w700);
    });

    test('text theme carries Inter and the roles', () {
      final textTheme = AppTypography.textTheme(
        Typography.material2021().black,
      );
      expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'Inter');
      expect(textTheme.displayLarge?.fontWeight, AppTypography.h1Weight);
      expect(textTheme.titleMedium?.fontWeight, FontWeight.w600);
      expect(textTheme.labelLarge?.fontWeight, FontWeight.w700);
    });

    test('roles are large enough to stay legible at 1.3x', () {
      const scaler = TextScaler.linear(AppTypography.maxTextScale);
      expect(
        AppTypography.lineHeight(AppTypography.body, scaler),
        greaterThan(AppTypography.body.fontSize!),
      );
    });
  });
}
