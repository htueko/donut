import 'package:flutter/material.dart';

/// Raw palette constants. Nothing here varies by brightness: widgets must read
/// semantic colors from [AppPalette] (via `context.palette`) or from
/// `Theme.of(context).colorScheme`, never from this class directly.
abstract final class AppColors {
  // Brand
  static const primaryCyan = Color(0xFF4EC5E6);
  static const primaryPink = Color(0xFFFF5398);
  static const accentOrange = Color(0xFFFF7E27);

  // Tier identity
  static const tierBronze = Color(0xFFC47F45);
  static const tierSilver = Color(0xFFB5B8BD);
  static const tierGold = Color(0xFFE5C158);
  static const tierPlatinum = Color(0xFF7AD7F0);

  // Neutrals shared by both modes
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // Light surfaces
  static const lightBackground = Color(0xFFFFF8F1);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFFFFFFF);
  static const lightSurfaceMuted = Color(0xFFFBF3EE);

  // Light text
  static const lightTextPrimary = Color(0xFF1D1512);
  static const lightTextSecondary = Color(0xFF6E544C);
  static const lightTextMuted = Color(0xFFB99C8F);

  // Light borders
  static const lightBorder = Color(0xFFEDE3DC);
  static const lightBorderStrong = Color(0xFFDCCFC6);

  // Dark surfaces
  static const darkBackground = Color(0xFF0E1114);
  static const darkSurface = Color(0xFF171B20);
  static const darkSurfaceElevated = Color(0xFF1F242A);
  static const darkSurfaceMuted = Color(0xFF1B2026);

  // Dark text
  static const darkTextPrimary = Color(0xFFF6F2EF);
  static const darkTextSecondary = Color(0xFFB9AFA9);
  static const darkTextMuted = Color(0xFF8C827C);

  // Dark borders
  static const darkBorder = Color(0xFF2A3037);
  static const darkBorderStrong = Color(0xFF3A424A);

  // Status
  static const dangerLight = Color(0xFFB3261E);
  static const dangerDark = Color(0xFFFF8A80);
  static const success = Color(0xFF74C69D);
  static const warning = Color(0xFFFFD166);

  // Shimmer
  static const shimmerBaseLight = Color(0xFFF1E9E3);
  static const shimmerHighlightLight = Color(0xFFFBF6F1);
  static const shimmerBaseDark = Color(0xFF232A31);
  static const shimmerHighlightDark = Color(0xFF2E363E);

  /// Tier identity is brightness independent, so it stays a lookup rather than
  /// a palette slot.
  static Color tierColor(String tier) {
    return switch (tier.toLowerCase()) {
      'bronze' => tierBronze,
      'silver' => tierSilver,
      'gold' => tierGold,
      'platinum' => tierPlatinum,
      _ => tierSilver,
    };
  }
}
