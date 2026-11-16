import 'package:intl/intl.dart';

/// Single place for locale-aware number formatting, so grouped digits (and
/// Burmese digits) look the same in every screen.
abstract final class DecimalFormatter {
  /// Formats [value] with [locale]'s digits and grouping.
  static String format(int value, {String? locale}) =>
      NumberFormat.decimalPattern(locale).format(value);
}
