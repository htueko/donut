import 'decimal_formatter.dart';

/// Formats a whole-number percentage (20 means 20%) using the locale's digits,
/// so Burmese renders "၂၀%" instead of "20%".
abstract final class PercentFormatter {
  static String format(int percent, {String? locale}) {
    return '${DecimalFormatter.format(percent, locale: locale)}%';
  }
}
