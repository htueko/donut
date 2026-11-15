import 'decimal_formatter.dart';

/// Formats [amount] for [locale], falling back to the ambient
/// `Intl.defaultLocale` when [locale] is null. [unit] is the localized
/// currency label so Burmese renders "ကျပ်" instead of "MMK".
abstract final class PriceMmkFormatter {
  static String format(int amount, {String? locale, String unit = 'MMK'}) {
    return '${DecimalFormatter.format(amount, locale: locale)} $unit';
  }
}
