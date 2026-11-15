import 'package:flutter/material.dart';

abstract final class AppColors {
  static const seed = Color(0xFFE5487A);
  static const cream = Color(0xFFFFF8F1);
  static const paper = Color(0xFFFFFFFF);
  static const chocolate = Color(0xFF43302B);
  static const cocoa = Color(0xFF6E544C);
  static const latte = Color(0xFFB99C8F);
  static const caramel = Color(0xFFF2A65A);
  static const glaze = Color(0xFFFFD166);
  static const mint = Color(0xFF74C69D);
  static const berry = Color(0xFF9D4EDD);
  static const danger = Color(0xFFB3261E);
  static const hairline = Color(0xFFEDE3DC);
  static const shimmerBase = Color(0xFFF1E9E3);
  static const shimmerHighlight = Color(0xFFFBF6F1);
  static const bronze = Color(0xFFC47F45);
  static const silver = Color(0xFFA9B4BE);
  static const gold = Color(0xFFE9B949);
  static const platinum = Color(0xFF6FB7C9);

  static Color tierColor(String tier) {
    return switch (tier.toLowerCase()) {
      'bronze' => bronze,
      'silver' => silver,
      'gold' => gold,
      'platinum' => platinum,
      _ => latte,
    };
  }
}
